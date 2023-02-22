require "rails_helper"

module StandardProcedure
  RSpec.describe WorkflowItem, type: :model do
    subject { a_saved StandardProcedure::WorkflowItem, group: employees, status: status, template: template, name: "Something" }
    let(:user) { a_saved ::User }
    let(:account) { a_saved(Account).configure_from(configuration) }
    let(:template) { account.templates.find_by reference: "order" }
    let(:workflow) { account.workflows.find_by reference: "order_processing" }
    let(:status) { workflow.statuses.find_by reference: "incoming" }
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

    it "assigns the item to a contact and notifies them" do
      subject.assign_to user, contact: nichola
      expect(subject.assigned_to).to eq nichola
      notification = nichola.notifications.last
      expect(notification).to_not be_nil
      expect(notification.linked_to? subject).to eq true
    end
  end
end
