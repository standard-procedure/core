require_relative "../rails_helper"

RSpec.describe StandardProcedure::HasCommands do
  let(:root) { a_saved User }
  let(:user) { User.create name: "Trevor Testington" }
  let(:second_user) { User.create name: "Stacey Soup-Spoon" }
  let(:category) { Category.create name: "Some things" }
  let(:sub_category) { Category.create parent: category, name: "More things" }
  let(:other_category) { Category.create name: "Other things" }
  let(:thing_1) { Thing.create category: category, name: "Thing 1" }
  let(:thing_2) { Thing.create category: category, name: "Thing 2" }

  it "knows which commands are available" do
    Category.class_eval do
      command(:first_command) { |performed_by:| puts "first" }
      command(:second_command) { |performed_by:| puts "second" }
    end

    expect(category.available_commands).to include(:first_command)
    expect(category.available_commands).to include(:second_command)
  end

  it "knows which commands are available for a given user" do
    Category.class_eval do
      command(:first_command) { |performed_by:| puts "first" }
      command(:second_command) { |performed_by:| puts "second" }
    end
    user.singleton_class.class_eval do
      def can?(perform_command, on_target)
        false
      end
    end
    second_user.singleton_class.class_eval do
      def can?(perform_command, on_target)
        (perform_command == :second_command) && (name == "Stacey Soup-Spoon")
      end
    end
    expect(category.available_commands_for(user)).to be_empty
    expect(category.available_commands_for(second_user)).to eq [:second_command]
  end

  it "records the commands performed to the command log" do
    Category.class_eval do
      command(:build_thing) do |name: "", performed_by: nil|
        things.create! name: name
      end
    end
    thing = category.build_thing name: "testfile.txt", performed_by: root

    expect(thing).to_not be_nil
    expect(thing.name).to eq "testfile.txt"

    command = category.commands.first
    expect(command).to_not be_nil
    expect(command.command).to eq "category_build_thing"
    expect(command.params[:name]).to eq "testfile.txt"
    expect(command.status).to eq "completed"
    expect(command.user).to eq root
    expect(command.result).to eq thing
    expect(command.context).to be_nil
    expect(category.commands).to include(command)
    expect(root.commands).to include(command)
    expect(thing.commands).to include(command)
  end

  it "links all related models to the command" do
    Category.class_eval do
      command(:move) do |thing:, destination:, performed_by:|
        thing.update category: destination
      end
    end

    category.move thing: thing_1, destination: other_category, performed_by: user

    command = category.commands.first
    expect(command).to_not be_nil
    expect(category.commands).to include(command)
    expect(other_category.commands).to include(command)
    expect(user.commands).to include(command)
    expect(thing_1.commands).to include(command)
  end

  it "nests commands within the command log" do
    Category.class_eval do
      command :move_things do |destination:, performed_by:, things: []|
        things.each do |thing|
          move thing: thing,
            destination: destination,
            performed_by: performed_by
        end
      end
      command(:move) do |thing:, destination:, performed_by:|
        thing.update category: destination
      end
    end

    category.move_things things: [thing_1, thing_2],
      destination: other_category,
      performed_by: root

    command = category.commands.find_by command: "category_move_things"
    expect(command).to_not be_nil
    expect(command.follow_on_commands.count).to eq 2
    command.follow_on_commands.each do |command|
      expect(command.command).to eq "category_move"
    end
  end

  it "records an error and re-raises if an exception is raised" do
    class GoneWrong < StandardError
    end

    Category.class_eval do
      command(:gone_wrong) { |performed_by:| raise GoneWrong }
    end

    expect { category.gone_wrong(performed_by: root) }.to raise_exception(
      GoneWrong
    )
    command = category.commands.first
    expect(command).to be_failed
    expect(command.error).to_not be_blank
  end

  it "does not perform a command if not authorised" do
    Category.class_eval do
      command(:build_thing) { |**params| "should never be called" }
    end
    allow(user).to receive(:can?).and_return(false)
    expect {
      category.build_thing name: "testfile.txt", performed_by: user
    }.to raise_exception(StandardProcedure::Command::Unauthorised)
  end

  it "defines a predefined command for adding to an association" do
    Category.class_eval { command :add_thing }

    expect(category).to respond_to :add_thing

    thing = category.add_thing name: "testfile.txt", performed_by: root
    expect(thing).to_not be_nil
    expect(thing.name).to eq "testfile.txt"
  end

  it "allows you to override the predefined command for adding an association" do
    Category.class_eval do
      command :add_thing do |name:, performed_by:|
        things.create! name: "override"
      end
    end

    expect(category).to respond_to :add_thing

    thing = category.add_thing name: "override", performed_by: root
    expect(thing).to_not be_nil
    expect(thing.name).to eq "override"
  end

  it "does not build predefined `add` commands if there is no association with that name" do
    Category.class_eval { command(:add_greeting) { |performed_by:| "Hello" } }
    result = category.add_greeting performed_by: root
    expect(result).to eq "Hello"
  end

  it "defines a predefined command for deleting an association" do
    Category.class_eval { command :remove_child }
    expect(category.available_commands).to include(:remove_child)
    category.remove_child child: sub_category, performed_by: user
    expect(Category.find_by(id: sub_category.id)).to be_nil
    command = user.commands.find_by command: "category_remove_child"
    expect(command).to_not be_nil
    expect(category.commands).to include(command)
  end

  it "allows you to override the predefined command for deleting an association" do
    Category.class_eval { command(:remove_child) { |**params| "do nothing" } }
    expect(category.available_commands).to include(:remove_child)
    category.remove_child child: sub_category, performed_by: user
    expect(Category.find_by(id: sub_category.id)).to_not be_nil
    command = user.commands.find_by command: "category_remove_child"
    expect(command).to_not be_nil
    expect(category.commands).to include(command)
  end

  it "allows you to define multiple predefined commands in one statement" do
    Category.class_eval { command :add_child, :remove_child }
    expect(category.available_commands).to include(:add_child)
    expect(category.available_commands).to include(:remove_child)
  end

  describe "when async is switched off" do
    it "does not allow asynchronous commands" do
      StandardProcedure.config.async = false

      Category.class_eval do
        command(:do_something) { |performed_by:| "whatever" }
      end
      expect(category.methods).to_not include(:do_something_later)
    end
  end

  describe "when async is switched to threader" do
    before { StandardProcedure.config.async = :threaded }

    it "performs a command later" do
      # How this test works:
      # We want to invoke a method that will be run in a background thread (using a Concurrent::Rails::Future).
      # However, we also need to check that the command is set up correctly before the thread completes.
      # So for the sake of this test, we use an implementation that waits until the test gives it a signal
      # (via a Concurrent::Ruby::MVar, which is a thread-safe variable), then when it's received that signal
      # it does the work and returns a result.
      # The test waits till the future has got a result, then checks that the command has also been updated
      # as expected
      # In a real app, you probably just want to "fire and forget" a load of method calls
      # so your method doesn't have to hang around waiting for lots of other work to complete.
      # In that case, you can just call the _later method and ignore the future that it returns
      Category.class_eval do
        def status
          # normally this would not be thread-safe but we are doing
          # all the initialisation in the main-thread so we're OK for this test
          @status ||= Concurrent::MVar.new
        end

        command :wait_then_do_something do |performed_by:|
          # Wait till the test gives us the go-ahead to get started
          status.take
          # Do some work here
          sleep 0.1
          # Wait till the test tells us to finish
          status.take
          # And return a result
          :done_something
        end
      end

      expect(category.commands).to be_empty
      # Calling _later will return a Concurrent::Rails::Future
      # which we can interrogate later on to find out when the task has completed
      future = category.wait_then_do_something_later(performed_by: root)
      expect(future.state).to eq :pending
      # Check that an command has been recorded for this command
      command =
        category.commands.find_by(command: "category_wait_then_do_something")
      expect(command).to_not be_nil
      expect(command).to be_ready
      # And now we can tell the command to do some work
      category.status.put :start_working
      command.reload
      expect(command).to be_in_progress
      category.status.put :stop_working
      # We use the future#value to wait until the command has completed
      expect(future.value).to eq :done_something
      # and check that the command has been updated correctly
      command.reload
      expect(command).to be_completed
      expect(command.result).to eq "done_something"
    end
  end
end
