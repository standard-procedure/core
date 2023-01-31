require_relative "../rails_helper"

RSpec.describe StandardProcedure::HasCommands do
  let(:person) { Person.create name: "Trevor Testington" }
  let(:folder) { Folder.create name: "My Documents" }

  it "records the actions performed to the command log" do
    Folder.class_eval do
      command(:build_document) { |user, params| documents.create! params }
      authorise(:build_document) { |user| true }
    end
    document = person.tells folder, to: :build_document, name: "testfile.txt"

    expect(document).to_not be_nil
    expect(document.name).to eq "testfile.txt"

    action = folder.actions.first
    expect(action).to_not be_nil
    expect(action.command).to eq "folder_build_document"
    expect(action.params["name"]).to eq "testfile.txt"
    expect(action.status).to eq "completed"
    expect(action.user).to eq person
    expect(action.result).to eq document
    expect(action.context).to be_nil
    expect(folder.actions).to include(action)
    expect(person.actions).to include(action)
    expect(document.actions).to include(action)
  end

  it "links all related models to the command"

  it "nests commands within the command log"

  it "does not perform a command if not authorised" do
    Folder.class_eval do
      authorise(:build_document) { |user| false }
    end

    expect { person.tells folder, to: :build_document, name: "testfile.txt" }.to raise_exception(StandardProcedure::Action::Unauthorised)
  end

  it "offers a predefined action for adding to an association" do
    Folder.class_eval do
      command :add_document
      authorise(:add_document) { |user| true }
    end

    expect(folder).to respond_to :add_document

    document = person.tells folder, to: :add_document, name: "testfile.txt"
    expect(document).to_not be_nil
    expect(document.name).to eq "testfile.txt"
  end

  it "does not build predefined actions if there is no association with that name" do
    Folder.class_eval do
      command(:add_greeting) { |user| "Hello" }
      authorise(:add_greeting) { |user| true }
    end
    result = person.tells folder, to: :add_greeting
    expect(result).to eq "Hello"
  end
  it "offers a predefined action for updating a model"
  it "offers a predefined action for deleting a model"
end
