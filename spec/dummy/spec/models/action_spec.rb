require_relative "../rails_helper"

RSpec.describe StandardProcedure::Action do
  let(:person) { Person.create name: "Trevor Testington" }
  let(:folder) { Folder.create name: "My Documents" }

  it "knows which actions it has defined" do
    expect(Folder.available_commands).to include(:build_document)
    expect(folder.available_commands).to include(:build_document)
  end

  it "records the actions performed to the command log" do
    document = person.tells folder, to: :build_document, name: "testfile.txt"

    expect(document).to_not be_nil
    expect(document.name).to eq "testfile.txt"

    action = folder.actions.first
    expect(action).to_not be_nil
    expect(action.command).to eq "folder_build_document"
    expect(action.params["name"]).to eq "testfile.txt"
    expect(action.user).to eq person
    expect(action.result).to eq document
    expect(action.context).to be_nil
  end

  it "nests commands within the command log"

  it "does not perform a command if not authorised" do
    Folder.class_eval do
      authorise :build_document do |user, params|
        false
      end
    end

    expect { person.tells folder, to: :build_document, name: "testfile.txt" }.to raise_exception(StandardProcedure::Action::Unauthorised)
  end

  it "offers a predefined action for adding to an association"
  it "offers a predefined action for updating a model"
  it "offers a predefined action for deleting a model"
end
