require "rails_helper"

module StandardProcedure
  RSpec.describe WorkflowStatus, type: :model do
    subject { workflow.statuses.find_by reference: "incoming" }
    let(:item) { a_saved StandardProcedure::WorkflowItem, group: employees, status: subject, template: template, name: "Something" }
    let(:user) { a_saved ::User }
    let(:account) { a_saved(Account).configure_from(configuration) }
    let(:template) { account.templates.find_by reference: "order" }
    let(:workflow) { account.workflows.find_by reference: "order_processing" }
    let(:staff) { account.roles.find_by reference: "staff" }
    let(:employees) { account.groups.find_by reference: "employees" }
    let(:nichola) { a_saved StandardProcedure::Contact, group: employees, role: staff, reference: "nichola@example.com" }
    let(:anna) { a_saved StandardProcedure::Contact, group: employees, role: staff, reference: "anna@example.com" }
    let :configuration do
      <<-YAML
        roles:
          - reference: staff
            name: Staff
        groups:
          - reference: employees
            name: Employees
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
                assign_to: nichola@example.com
                alerts:
                  - hours: 48
                    type: StandardProcedure::Alert::SendNotification
                    contacts:
                      - anna@example.com
              - reference: in_progress
                name: In Progress
                position: 2
      YAML
    end
    it "sets the default assignment on the item when it is added" do
      anna.touch
      nichola.touch

      subject.item_added user, item: item
      expect(item.assigned_to).to eq nichola
    end
    it "adds alerts to an item when it is added" do
      Timecop.freeze(Time.now) do
        anna.touch
        nichola.touch

        subject.item_added user, item: item
        expect(item.alerts).to_not be_empty
        alert = item.alerts.first
        expect(alert.due_at.to_date).to eq (Date.today + 2)
        expect(alert.contacts).to include anna
      end
    end
  end
end
