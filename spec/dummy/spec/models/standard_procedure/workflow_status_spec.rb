require "rails_helper"

module StandardProcedure
  RSpec.describe WorkflowStatus, type: :model do
    subject { workflow.statuses.find_by reference: "incoming" }
    let(:item) { a_saved StandardProcedure::WorkflowItem, group: group, status: subject, template: template, name: "Something" }
    let(:user) { a_saved ::User }
    let(:account) { a_saved(Account).configure_from(configuration) }
    let(:template) { account.templates.find_by reference: "order" }
    let(:workflow) { account.workflows.find_by reference: "order_processing" }
    let :configuration do
      <<-YAML
        templates:
          - reference: order 
            name: Order
        workflows:
          - reference: order_processing
            name: Order Processeing
            statuses:
              - reference: incoming
                name: Incoming
                position: 1
                alerts:
                  - hours: 48
                    type: StandardProcedure::Deadline::SendNotification
                    contacts:
                      - anna@example.com
                        nichola@example.com
              - reference: in_progress
                name: In Progress
                position: 2
      YAML
    end
    it "adds alerts to an item when it is added" do
      subject.item_added user, item: item
      expect(item.alerts).to_not be_empty
      alert = item.alerts.first
      expect(alert.due_on).to eq 48.hours.from_now
    end
  end
end
