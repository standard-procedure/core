require "rails_helper"

module StandardProcedure
  RSpec.describe Contact, type: :model do
    subject { a_saved_contact_called "Anna" }
    let(:user) { subject.user }
    let(:account) { subject.account }
    let(:nathan) { a_saved_contact_called "Nathan", account: account }

    describe "messages" do
      it "sends messages to other contacts" do
        nathan.touch

        subject.send_message user, recipients: [nathan], subject: "Hello", contents: "World!"

        message = subject.sent_messages.last
        expect(message).to_not be_nil
        expect(nathan.messages).to include(message)
        notification = nathan.notifications.last
        expect(notification).to_not be_nil
        expect(notification.model_name.to_s).to eq "StandardProcedure::Notification::MessageReceived"
        expect(notification.message).to eq message
        expect(notification.details.to_s).to include("World!")
      end
    end
  end
end
