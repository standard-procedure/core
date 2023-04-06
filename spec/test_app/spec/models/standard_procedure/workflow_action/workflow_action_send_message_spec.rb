require "rails_helper"

module StandardProcedure
  RSpec.describe WorkflowAction::SendMessage, type: :model do
    let(:document) { a_saved_document_titled "Something" }
    let(:account) { document.account }
    let(:sender) { a_saved_contact_called "User", account: account, user: user }
    let(:user) { a_saved User }
    let(:first) { a_saved_contact_called "First", account: account }
    let(:second) { a_saved_contact_called "Second", account: account }

    before { sender.touch }

    it "creates a message for the recipients and links it to the document" do
      message = double("StandardProcedure::Message")
      # have to use any_instance_of because a different instance of sender gets loaded by the action
      expect_any_instance_of(StandardProcedure::Contact).to receive(
        :send_message
      ).with(
        performed_by: user,
        recipients: [first, second],
        subject: "Test",
        contents: "<div class=\"trix-content\">\n  Message\n</div>\n"
      ).and_return message
      expect(message).to receive(:link_to).with(document)
      WorkflowAction::SendMessage.perform document: document,
        subject: "Test",
        contents: "Message",
        reminder_after: 24,
        recipients: [first, second],
        performed_by: user
    end
    it "sets a reminder for the sender" do
      Timecop.freeze do
        expect(document).to receive(:add_alert).with(
          type: "StandardProcedure::Alert::SendNotification",
          due_at: 24.hours.from_now,
          message: "Follow up on sent message: Test",
          contacts: [sender],
          performed_by: user
        )
        WorkflowAction::SendMessage.perform document: document,
          subject: "Test",
          contents: "Message",
          reminder_after: 24,
          recipients: [first, second],
          performed_by: user
      end
    end
  end
end
