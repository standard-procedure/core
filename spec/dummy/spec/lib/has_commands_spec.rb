require_relative "../rails_helper"

RSpec.describe StandardProcedure::HasCommands do
  let(:person) { Person.create name: "Trevor Testington" }
  let(:second_person) { Person.create name: "Stacey Soup-Spoon" }
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
    Person.class_eval do
      def can?(command, target)
        (command == :second_command) && (name == "Stacey Soup-Spoon")
      end
    end
    expect(category.available_commands_for(person)).to be_empty
    expect(category.available_commands_for(second_person)).to eq [:second_command]
  end

  it "records the actions performed to the command log" do
    Category.class_eval do
      command(:build_thing) do |user, params|
        things.create! params
      end
    end
    Person.class_eval do
      def can?(command, target)
        true
      end
    end
    thing = category.build_thing person, name: "testfile.txt"

    expect(thing).to_not be_nil
    expect(thing.name).to eq "testfile.txt"

    action = category.actions.first
    expect(action).to_not be_nil
    expect(action.command).to eq "category_build_thing"
    expect(action.params["name"]).to eq "testfile.txt"
    expect(action.status).to eq "completed"
    expect(action.user).to eq person
    expect(action.result).to eq thing
    expect(action.context).to be_nil
    expect(category.actions).to include(action)
    expect(person.actions).to include(action)
    expect(thing.actions).to include(action)
  end

  it "links all related models to the command" do
    Category.class_eval do
      command(:move_thing) { |user, params| params[:thing].update category: params[:destination] }
    end
    Person.class_eval do
      def can?(command, target)
        true
      end
    end

    category.move_thing person, thing: thing_1, destination: other_category

    action = category.actions.first
    expect(action).to_not be_nil
    expect(category.actions).to include(action)
    expect(other_category.actions).to include(action)
    expect(person.actions).to include(action)
    expect(thing_1.actions).to include(action)
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
    Person.class_eval do
      def can?(command, target)
        true
      end
    end

    category.move_things person, things: [thing_1, thing_2], destination: other_category

    action = category.actions.find_by command: "category_move_things"
    expect(action).to_not be_nil
    expect(action.follow_on_actions.count).to eq 2
    action.follow_on_actions.each do |action|
      expect(action.command).to eq "category_move_thing"
    end
  end

  it "records an error and re-raises if an exception is raised" do
    class GoneWrong < StandardError
    end

    Category.class_eval do
      command(:gone_wrong) { |user| raise GoneWrong }
    end
    Person.class_eval do
      def can?(command, target)
        true
      end
    end

    expect { category.gone_wrong(person) }.to raise_exception(GoneWrong)
    action = category.actions.first
    expect(action).to be_failed
    expect(action.params["error"]).to_not be_blank
  end

  it "does not perform a command if not authorised" do
    Category.class_eval do
      command(:build_thing) { |user, **params| "should never be called" }
    end
    Person.class_eval do
      def can?(command, target)
        false
      end
    end

    expect { category.build_thing person, name: "testfile.txt" }.to raise_exception(StandardProcedure::Action::Unauthorised)
  end

  it "defines a predefined command for adding to an association" do
    Category.class_eval do
      command :add_thing
    end
    Person.class_eval do
      def can?(command, target)
        true
      end
    end

    expect(category).to respond_to :add_thing

    thing = category.add_thing person, name: "testfile.txt"
    expect(thing).to_not be_nil
    expect(thing.name).to eq "testfile.txt"
  end

  it "allows you to override the predefined command for adding an association" do
    Category.class_eval do
      command :add_thing do |user, **params|
        things.create! name: "override"
      end
    end
    Person.class_eval do
      def can?(command, target)
        true
      end
    end

    expect(category).to respond_to :add_thing

    thing = category.add_thing person, name: "override"
    expect(thing).to_not be_nil
    expect(thing.name).to eq "override"
  end

  it "does not build predefined `add` commands if there is no association with that name" do
    Category.class_eval do
      command(:add_greeting) { |user| "Hello" }
    end
    Person.class_eval do
      def can?(command, target)
        true
      end
    end
    result = category.add_greeting person
    expect(result).to eq "Hello"
  end

  it "adds a predefined amend command automatically" do
    Category.class_eval do
      defines_commands
    end
    Person.class_eval do
      def can?(command, target)
        true
      end
    end
    expect(Category.available_commands).to include(:amend)
    category.amend person, name: "Another name"
    expect(category.name).to eq "Another name"
    action = category.actions.find_by command: "category_amend"
    expect(action).to_not be_nil
  end

  it "defines a predefined command for deleting an association" do
    Category.class_eval do
      command :remove_child
    end
    Person.class_eval do
      def can?(command, target)
        true
      end
    end
    expect(category.available_commands).to include(:remove_child)
    category.remove_child person, child: sub_category
    expect(Category.find_by id: sub_category.id).to be_nil
    action = person.actions.find_by command: "category_remove_child"
    expect(action).to_not be_nil
    expect(category.actions).to include(action)
  end

  it "allows you to override the predefined command for deleting an association" do
    Category.class_eval do
      command(:remove_child) { |user, **params| "do nothing" }
    end
    Person.class_eval do
      def can?(command, target)
        true
      end
    end
    expect(category.available_commands).to include(:remove_child)
    category.remove_child person, child: sub_category
    expect(Category.find_by id: sub_category.id).to_not be_nil
    action = person.actions.find_by command: "category_remove_child"
    expect(action).to_not be_nil
    expect(category.actions).to include(action)
  end

  it "allows you to define multiple predefined commands in one statement" do
    Category.class_eval do
      command :add_child, :remove_child
    end
    expect(category.available_commands).to include(:add_child)
    expect(category.available_commands).to include(:remove_child)
  end

  it "performs a command later" do
    # How this test works:
    # We want to invoke a method that will be run in a background thread (using a Concurrent::Rails::Future).
    # However, we also need to check that the action is set up correctly before the thread completes.
    # So for the sake of this test, we use an implementation that waits until the test gives it a signal
    # (via a Concurrent::Ruby::MVar, which is a thread-safe variable), then when it's received that signal
    # it does the work and returns a result.
    # The test waits till the future has got a result, then checks that the action has also been updated
    # as expected
    # In a real app, you probably just want to "fire and forget" a load of method calls
    # so your method doesn't have to hang around waiting for lots of other work to complete.
    # In that case, you can just call the _later method and ignore the future that it returns
    Person.class_eval do
      def can?(command, target)
        true
      end
    end
    Category.class_eval do
      def status
        # normally this would not be thread-safe but we are doing
        # all the initialisation in the main-thread so we're OK for this test
        @status ||= Concurrent::MVar.new
      end

      command :wait_then_do_something do |user|
        # Wait till the test gives us the go-ahead to get started
        status.take
        # Do some work here
        sleep 0.1
        # And return a result
        :update_completed
      end
    end

    expect(category.actions).to be_empty
    # Calling _later will return a Concurrent::Rails::Future
    # that we can interrogate later on to find out when the task has completed
    future = category.wait_then_do_something_later(person)
    expect(future.state).to eq :pending
    # Check that an action has been recorded for this command
    action = category.actions.find_by(command: "category_wait_then_do_something")
    expect(action).to_not be_nil
    expect(action).to be_in_progress
    # And now we can tell the command to do some work
    category.status.put :start_working
    # We use the future#value to wait until the command has completed
    expect(future.value).to eq :update_completed
    # and check that the action has been updated correctly
    action.reload
    expect(action).to be_completed
    expect(action.result).to eq "update_completed"
  end
end
