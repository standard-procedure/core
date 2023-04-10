require "rails_helper"

module StandardProcedure
  RSpec.describe Alert::SendNotification, type: :model do
    let(:thing) { Thing.create name: "Thing" }
    let(:alice) { a_saved User }
    let(:bob) { a_saved User }
    let(:chris) { a_saved User }

    it "sends notifications to each contact" do
      alert = Alert::SendNotification.create! item: thing, due_at: 1.minute.ago, status: "active", message: "Here is your notification", recipients: [alice, bob]
      alert.trigger

      [alice, bob].each do |user|
        notification = user.notifications.first
        expect(notification).to_not be_nil
        expect(notification.linked_to?(thing)).to eq true
        expect(notification.details.to_s).to include("Here is your notification")
      end
    end
  end
end
