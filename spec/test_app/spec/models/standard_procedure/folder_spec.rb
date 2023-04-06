require "rails_helper"

module StandardProcedure
  RSpec.describe Folder, type: :model do
    subject { a_saved Folder, account: account, parent: contact }
    let(:account) { a_saved Account }
    let(:contact) { a_saved_contact_called "Dave", account: account }
    let(:organisation) { contact.organisation }
    let(:user) { contact.user }

    it "adds a file" do
      test_file = ::File.open(Rails.root.join("spec", "files", "test-file.txt"))
      uploaded_file = subject.upload_file name: "test-file.txt", io: test_file, performed_by: user
      expect(uploaded_file).to_not be_nil
      expect(uploaded_file.contact).to eq contact
      expect(uploaded_file.file).to be_attached
      expect(uploaded_file.file.download).to eq "# Test\n"
    end
    it "creates a slot"
    it "creates a document"

    it "knows which contact it belongs to" do
      expect(subject.contact).to eq contact
    end
    it "knows which organisation it belongs to" do
      expect(subject.organisation).to eq organisation
    end

    it "tells the account to add a sub-folder" do
      expect(account).to receive(:add_folder).with(parent: subject, name: "Sub-Folder", reference: "ABC123", performed_by: user)
      subject.add_folder name: "Sub-Folder", reference: "ABC123", performed_by: user
    end
    it "tells the account to remove itself" do
      expect(account).to receive(:remove_folder).with(folder: subject, performed_by: user)
      subject.delete performed_by: user
    end
  end
end
