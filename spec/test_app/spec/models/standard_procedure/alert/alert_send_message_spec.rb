require "rails_helper"

module StandardProcedure
  RSpec.describe Alert::SendMessage, type: :model do
    let(:thing) { a_saved Thing, name: "Thing" }
    let(:alice) { a_saved User, reference: "alice" }
    let(:bob) { a_saved User, reference: "bob" }
    let(:chris) { a_saved User, reference: "chris" }

    it "sends messages to each recipient from the given user" do
      [alice, bob, chris].each(&:touch)

      alert = Alert::SendMessage.create! alertable: thing, sender: "chris", due_at: 1.minute.ago, status: "active", subject: "New message", message: "Here is your message", recipients: [alice, bob]
      alert.trigger

      [alice, bob].each do |user|
        message = user.messages.first
        expect(message).to_not be_nil
        expect(message.linked_to?(thing)).to eq true
        expect(message.subject).to eq "New message"
        expect(message.contents.to_plain_text).to include("Here is your message")
        expect(message.sender).to eq chris
      end

      message = chris.sent_messages.first
      expect(message).to_not be_nil
      expect(message.linked_to?(thing)).to eq true
      expect(message.subject).to eq "New message"
      expect(message.contents.to_plain_text).to include("Here is your message")
      expect(message.recipients).to eq [alice, bob]
    end
  end
end
