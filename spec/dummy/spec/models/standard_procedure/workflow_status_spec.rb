require "rails_helper"

module StandardProcedure
  RSpec.describe WorkflowStatus, type: :model do
    subject { workflow.statuses.find_by reference: "incoming" }
    let(:item) { a_saved StandardProcedure::WorkflowItem, type: "Order", group: employees, status: subject, template: template, name: "Something" }
    let(:user) { a_saved ::User }
    let(:account) { a_saved(Account).configure_from(configuration) }
    let(:template) { account.templates.find_by reference: "order" }
    let(:workflow) { account.workflows.find_by reference: "order_processing" }
    let(:staff) { account.roles.find_by reference: "staff" }
    let(:employees) { account.groups.find_by reference: "employees" }
    let(:suppliers) { account.groups.find_by reference: "suppliers" }
    let(:nichola) { a_saved StandardProcedure::Contact, group: employees, role: staff, reference: "nichola@example.com" }
    let(:anna) { a_saved StandardProcedure::Contact, group: employees, role: staff, reference: "anna@example.com" }
    let(:supplier_1) { a_saved StandardProcedure::Contact, group: suppliers, role: supplier, reference: "supplier1@example.com" }
    let :configuration do
      <<-YAML
        roles:
          - reference: staff
            name: Staff
          - reference: supplier
            name: Supplier
        groups:
          - reference: employees
            name: Employee
          - reference: suppliers
            name: Supplier
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
                actions:
                  - reference: place_order_with_supplier
                    name: Place order with Supplier
                  - reference: make_priority
                    name: Make this a priority order
                    type: MakePriorityOrder
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

    class ::Order < StandardProcedure::WorkflowItem 
      has_field :priority, default: "low"
    end

    class ::MakePriorityOrder < StandardProcedure::WorkflowAction
      has_field :escalation_reason
      validates :escalation_reason, presence: true 
    
      def perform 
        item.update! priority: "high"
      end
    end

    it "knows which actions are available" do
      expect(subject.available_actions).to eq ["place_order_with_supplier", "make_priority"]
    end
    it "knows the names of the available actions" do
      expect(subject.name_for(:place_order_with_supplier)).to eq "Place order with Supplier"
      expect(subject.name_for(:make_priority)).to eq "Make this a priority order"
      expect { subject.name_for(:something_else) }.to raise_exception(StandardProcedure::WorkflowStatus::InvalidActionReference)
    end
    it "builds an action" do 
      expect(subject.build_action(:place_order_with_supplier).class.name).to eq "StandardProcedure::WorkflowAction::UserDefined"
      expect(subject.build_action(:make_priority).class.name).to eq "MakePriorityOrder"
      expect { subject.build_action(:something_else) }.to raise_exception(StandardProcedure::WorkflowStatus::InvalidActionReference)
    end
    it "performs an action via a ruby class" do
      action = subject.perform_action(user, action_reference: "make_priority", item: item, escalation_reason: "It's urgent")
      expect(action.escalation_reason).to eq "It's urgent"
      expect(action.item.priority).to eq "high"
    end
    it "performs a user-defined action" do
      expect_any_instance_of(StandardProcedure::WorkflowAction::UserDefined).to receive(:perform)
      subject.perform_action user, action_reference: "place_order_with_supplier", item: item
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

    it "deactivates any existing alerts when it is added" do 
      anna.touch
      nichola.touch
      existing_alert = item.alerts.create! due_at: 2.days.from_now, status: "waiting", contacts: [anna, nichola]

      subject.item_added user, item: item 

      existing_alert.reload 
      expect(existing_alert).to be_inactive
    end
  end
end