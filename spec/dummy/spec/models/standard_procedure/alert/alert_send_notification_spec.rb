require "rails_helper"

module StandardProcedure
  RSpec.describe Alert::SendNotification, type: :model do
    let(:account) { a_saved Account }
    let(:thing) { Thing.create name: "Thing" }
    let(:alice) { a_saved_contact_called "Alice", account: account }
    let(:bob) { a_saved_contact_called "Bob", account: account }
    let(:chris) { a_saved_contact_called "Chris", account: account }

    it "sends notifications to each contact" do
      alert =
        Alert::SendNotification.create! item: thing,
                                        due_at: 1.minute.ago,
                                        status: "active",
                                        message: "Here is your notification",
                                        contacts: [alice, bob]
      alert.trigger

      [alice, bob].each do |contact|
        notification = contact.notifications.first
        expect(notification).to_not be_nil
        expect(notification.linked_to?(thing)).to eq true
        expect(notification.details.to_s).to include(
          "Here is your notification",
        )
      end
    end
  end
end
