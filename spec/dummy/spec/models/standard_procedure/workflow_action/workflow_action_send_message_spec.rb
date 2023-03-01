require "rails_helper"

module StandardProcedure
  RSpec.describe WorkflowAction::SendMessage, type: :model do
    let(:item) { a_saved_item_titled "Something" }
    let(:account) { item.account }
    let(:sender) { a_saved_contact_called "Someone", account: account, user: user }
    let(:user) { a_saved User }
    let(:first) { a_saved_contact_called "First", account: account }
    let(:second) { a_saved_contact_called "Second", account: account }

    it "creates a message for the recipients and links it to the item" do
      sender.touch
      message = double("StandardProcedure::Message")
      # have to use any_instance_of because a different instance of sender gets loaded by the action
      expect_any_instance_of(StandardProcedure::Contact).to receive(:send_message).with(user, recipients: [first, second], subject: "Test", contents: "<div class=\"trix-content\">\n  Message\n</div>\n").and_return message
      expect(message).to receive(:link_to).with(item)
      WorkflowAction::SendMessage.perform user: user, item: item, subject: "Test", contents: "Message", reminder_after: 24, recipients: [first, second]
    end
    it "sets a reminder for the sender" do
      Timecop.freeze do
        expect(item).to receive(:add_alert).with(user, type: "StandardProcedure::Alert::SendNotification", due_at: 24.hours.from_now, message: "Follow up on sent message: Test", contacts: [sender])
        WorkflowAction::SendMessage.perform user: user, item: item, subject: "Test", contents: "Message", reminder_after: 24, recipients: [first, second]
      end
    end
  end
end
