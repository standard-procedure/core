require "rails_helper"

module StandardProcedure
  RSpec.describe Alert, type: :model do
    let(:account) { a_saved Account }
    let(:thing) { Thing.create name: "Thing" }
    let(:alice) { a_saved_contact_called "Alice", account: account }
    let(:bob) { a_saved_contact_called "Bob", account: account }

    it "is due if active and past the recorded due-time" do
      Timecop.freeze do
        alert = Alert.create! item: thing, due_at: 1.minute.ago, status: "active"
        expect(alert).to be_due
        alert = Alert.create! item: thing, due_at: 1.minute.ago, status: "triggered"
        expect(alert).to_not be_due
        alert = Alert.create! item: thing, due_at: 1.minute.from_now, status: "active"
        expect(alert).to_not be_due
      end
    end

    it "does not trigger until it is due" do
      alert = Alert.create! item: thing, due_at: 2.hours.from_now, status: "active"
      expect(alert).to_not receive(:perform)
      alert.trigger
      expect(alert).to be_active
    end

    it "can be forced to trigger before it is due" do
      alert = Alert.create! item: thing, due_at: 2.hours.from_now, status: "active"
      expect(alert).to receive(:perform)
      alert.trigger(force: true)
      expect(alert).to be_triggered
    end

    it "triggers when it is due" do
      alert = Alert.create! item: thing, due_at: 2.minutes.ago, status: "active"
      expect(alert).to receive(:perform)
      alert.trigger
      expect(alert).to be_triggered
    end

    it "does not trigger if it has previously triggered" do
      alert = Alert.create! item: thing, due_at: 2.minutes.ago, status: "triggered"
      expect(alert).to_not receive(:perform)
      alert.trigger
      expect(alert).to be_triggered
    end

    it "can be forced to trigger if it has previously triggered" do
      alert = Alert.create! item: thing, due_at: 2.minutes.ago, status: "triggered"
      expect(alert).to receive(:perform)
      alert.trigger(force: true)
      expect(alert).to be_triggered
    end

    it "does not trigger if it has been acknowledged" do
      alert = Alert.create! item: thing, due_at: 2.minutes.ago, status: "acknowledged"
      expect(alert).to_not receive(:perform)
      alert.trigger
      expect(alert).to be_acknowledged
    end

    it "does not trigger if it is inactive" do
      alert = Alert.create! item: thing, due_at: 2.minutes.ago, status: "inactive"
      expect(alert).to_not receive(:perform)
      alert.trigger
      expect(alert).to be_inactive
    end
  end
end
