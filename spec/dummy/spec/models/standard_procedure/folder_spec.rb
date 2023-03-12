require "rails_helper"

module StandardProcedure
  RSpec.describe Folder, type: :model do
    subject { a_saved Folder }
    let(:account) { subject.account }
    let(:contact) { a_saved_contact_called "Dave", account: account }
    let(:user) { contact.user }

    it "adds a file" do
      test_file = File.open(Rails.root.join("spec", "files", "test-file.txt"))
      uploaded_file =
        subject.upload_file name: "test-file.txt",
                            io: test_file,
                            performed_by: user
      expect(uploaded_file).to_not be_nil
      expect(uploaded_file.owner).to eq contact
      expect(uploaded_file.contents).to be_attached
      expect(uploaded_file.contents.download).to eq "# Test"
    end
    it "creates a slot"
    it "creates a document" do
    end
  end
end
