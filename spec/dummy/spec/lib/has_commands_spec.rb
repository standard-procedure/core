require_relative "../rails_helper"

RSpec.describe StandardProcedure::HasCommands do
  let(:user) { StandardProcedure::User.create name: "Trevor Testington" }
  let(:second_user) { User.create name: "Stacey Soup-Spoon" }
  let(:category) { Category.create name: "Some things" }
  let(:sub_category) { Category.create parent: category, name: "More things" }
  let(:other_category) { Category.create name: "Other things" }
  let(:thing_1) { Thing.create category: category, name: "Thing 1" }
  let(:thing_2) { Thing.create category: category, name: "Thing 2" }

  it "knows which commands are available" do
    Category.class_eval do
      command(:first_command) { |user| puts "first" }
      command(:second_command) { |user| puts "second" }
    end

    expect(category.available_commands).to include(:first_command)
    expect(category.available_commands).to include(:second_command)
  end

  it "knows which commands are available for a given user" do
    Category.class_eval do
      command(:first_command) { |user| puts "first" }
      command(:second_command) { |user| puts "second" }
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
      command(:build_thing) do |user, params|
        things.create! params
      end
    end
    thing = category.build_thing User.root, name: "testfile.txt"

    expect(thing).to_not be_nil
    expect(thing.name).to eq "testfile.txt"

    command = category.commands.first
    expect(command).to_not be_nil
    expect(command.command).to eq "category_build_thing"
    expect(command.params[:name]).to eq "testfile.txt"
    expect(command.status).to eq "completed"
    expect(command.user).to eq User.root
    expect(command.result).to eq thing
    expect(command.context).to be_nil
    expect(category.commands).to include(command)
    expect(User.root.commands).to include(command)
    expect(thing.commands).to include(command)
  end

  it "links all related models to the command" do
    Category.class_eval do
      command(:move_thing) { |user, params| params[:thing].update category: params[:destination] }
    end

    category.move_thing User.root, thing: thing_1, destination: other_category

    command = category.commands.first
    expect(command).to_not be_nil
    expect(category.commands).to include(command)
    expect(other_category.commands).to include(command)
    expect(user.commands).to include(command)
    expect(thing_1.commands).to include(command)
  end

  it "nests commands within the command log" do
    Category.class_eval do
      command :move_things do |user, params|
        params[:things].each do |thing|
          move_thing user, thing: thing, destination: params[:destination]
        end
      end
      command(:move_thing) do |user, params|
        params[:thing].update category: params[:destination]
      end
    end

    category.move_things User.root, things: [thing_1, thing_2], destination: other_category

    command = category.commands.find_by command: "category_move_things"
    expect(command).to_not be_nil
    expect(command.follow_on_commands.count).to eq 2
    command.follow_on_commands.each do |command|
      expect(command.command).to eq "category_move_thing"
    end
  end

  it "records an error and re-raises if an exception is raised" do
    class GoneWrong < StandardError
    end

    Category.class_eval do
      command(:gone_wrong) { |user| raise GoneWrong }
    end

    expect { category.gone_wrong(User.root) }.to raise_exception(GoneWrong)
    command = category.commands.first
    expect(command).to be_failed
    expect(command.error).to_not be_blank
  end

  it "does not perform a command if not authorised" do
    Category.class_eval do
      command(:build_thing) { |user, **params| "should never be called" }
    end
    allow(user).to receive(:can?).and_return(false)
    expect { category.build_thing user, name: "testfile.txt" }.to raise_exception(StandardProcedure::Command::Unauthorised)
  end

  it "defines a predefined command for adding to an association" do
    Category.class_eval do
      command :add_thing
    end

    expect(category).to respond_to :add_thing

    thing = category.add_thing User.root, name: "testfile.txt"
    expect(thing).to_not be_nil
    expect(thing.name).to eq "testfile.txt"
  end

  it "allows you to override the predefined command for adding an association" do
    Category.class_eval do
      command :add_thing do |user, **params|
        things.create! name: "override"
      end
    end

    expect(category).to respond_to :add_thing

    thing = category.add_thing User.root, name: "override"
    expect(thing).to_not be_nil
    expect(thing.name).to eq "override"
  end

  it "does not build predefined `add` commands if there is no association with that name" do
    Category.class_eval do
      command(:add_greeting) { |user| "Hello" }
    end
    result = category.add_greeting User.root
    expect(result).to eq "Hello"
  end

  it "adds a predefined amend command automatically" do
    Category.class_eval do
      defines_commands
    end
    expect(Category.available_commands).to include(:amend)
    category.amend User.root, name: "Another name"
    expect(category.name).to eq "Another name"
    command = category.commands.find_by command: "category_amend"
    expect(command).to_not be_nil
  end

  it "defines a predefined command for deleting an association" do
    Category.class_eval do
      command :remove_child
    end
    expect(category.available_commands).to include(:remove_child)
    category.remove_child User.root, child: sub_category
    expect(Category.find_by id: sub_category.id).to be_nil
    command = user.commands.find_by command: "category_remove_child"
    expect(command).to_not be_nil
    expect(category.commands).to include(command)
  end

  it "allows you to override the predefined command for deleting an association" do
    Category.class_eval do
      command(:remove_child) { |user, **params| "do nothing" }
    end
    expect(category.available_commands).to include(:remove_child)
    category.remove_child User.root, child: sub_category
    expect(Category.find_by id: sub_category.id).to_not be_nil
    command = user.commands.find_by command: "category_remove_child"
    expect(command).to_not be_nil
    expect(category.commands).to include(command)
  end

  it "allows you to define multiple predefined commands in one statement" do
    Category.class_eval do
      command :add_child, :remove_child
    end
    expect(category.available_commands).to include(:add_child)
    expect(category.available_commands).to include(:remove_child)
  end

  describe "when async is switched off" do
    it "does not allow asynchronous commands" do
      StandardProcedure.config.async = false

      Category.class_eval do
        command(:do_something) { |user| "whatever" }
      end
      expect(category.methods).to_not include(:do_something_later)
    end
  end

  describe "when async is switched on" do
    before do
      StandardProcedure.config.async = true
    end

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

        command :wait_then_do_something do |user|
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
      future = category.wait_then_do_something_later(User.root)
      expect(future.state).to eq :pending
      # Check that an command has been recorded for this command
      command = category.commands.find_by(command: "category_wait_then_do_something")
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
