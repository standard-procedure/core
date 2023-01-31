require_relative "../rails_helper"

RSpec.describe StandardProcedure::HasCommands do
  let(:person) { Person.create name: "Trevor Testington" }
  let(:folder) { Folder.create name: "My Documents" }
  let(:other_folder) { Folder.create name: "Other Documents" }
  let(:document_1) { Document.create folder: folder, name: "Document 1" }
  let(:document_2) { Document.create folder: folder, name: "Document 2" }

  it "records the actions performed to the command log" do
    Folder.class_eval do
      command(:build_document) do |user, params|
        documents.create! params
      end
      authorise(:build_document) { |user| true }
    end
    document = folder.build_document person, name: "testfile.txt"

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

  it "links all related models to the command" do
    Folder.class_eval do
      command(:move_document) { |user, params| params[:document].update folder: params[:destination] }
      authorise(:move_document) { |user| true }
    end

    folder.move_document person, document: document_1, destination: other_folder

    action = folder.actions.first
    expect(action).to_not be_nil
    expect(folder.actions).to include(action)
    expect(other_folder.actions).to include(action)
    expect(person.actions).to include(action)
    expect(document_1.actions).to include(action)
  end

  it "nests commands within the command log" do
    Folder.class_eval do
      command :move_documents do |user, params|
        params[:documents].each do |document|
          move_document user, document: document, destination: params[:destination]
        end
      end
      command(:move_document) do |user, params|
        params[:document].update folder: params[:destination]
      end
      authorise(:move_document) { |user| true }
      authorise(:move_documents) { |user| true }
    end

    folder.move_documents person, documents: [document_1, document_2], destination: other_folder

    action = folder.actions.find_by command: "folder_move_documents"
    expect(action).to_not be_nil
    expect(action.follow_on_actions.count).to eq 2
    action.follow_on_actions.each do |action|
      expect(action.command).to eq "folder_move_document"
    end
  end

  it "records an error and re-raises if an exception is raised" do
    class GoneWrong < StandardError
    end

    Folder.class_eval do
      command(:gone_wrong) { |user| raise GoneWrong }
      authorise(:gone_wrong) { |user| true }
    end

    expect { folder.gone_wrong(person) }.to raise_exception(GoneWrong)
    action = folder.actions.first
    expect(action).to be_failed
    expect(action.params["error"]).to_not be_blank
  end

  it "performs a command asynchronously"

  it "does not perform a command if not authorised" do
    Folder.class_eval do
      authorise(:build_document) { |user| false }
    end

    expect { folder.build_document person, name: "testfile.txt" }.to raise_exception(StandardProcedure::Action::Unauthorised)
  end

  it "defines a predefined command for adding to an association" do
    Folder.class_eval do
      command :add_document
      authorise(:add_document) { |user| true }
    end

    expect(folder).to respond_to :add_document

    document = folder.add_document person, name: "testfile.txt"
    expect(document).to_not be_nil
    expect(document.name).to eq "testfile.txt"
  end

  it "does not build predefined `add` commands if there is no association with that name" do
    Folder.class_eval do
      command(:add_greeting) { |user| "Hello" }
      authorise(:add_greeting) { |user| true }
    end
    result = folder.add_greeting person
    expect(result).to eq "Hello"
  end
end