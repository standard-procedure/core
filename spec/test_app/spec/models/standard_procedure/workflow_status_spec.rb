require "rails_helper"

module StandardProcedure
  class Order < Thing
    has_field :priority, default: "low"
  end

  class MakePriorityOrder < StandardProcedure::WorkflowAction
    has_field :escalation_reason
    validates :escalation_reason, presence: true

    def perform
      document.update! priority: "high"
    end
  end

  RSpec.describe WorkflowStatus, type: :model do
    subject { workflow.statuses.find_by reference: "incoming" }
    let(:account) { a_saved Category }
    let(:document) { a_saved Thing }

    let(:user) { a_saved User }
    let(:workflow) { a_saved Workflow, account: account }
    let(:nichola) { a_saved User, reference: "nichola@example.com" }
    let(:anna) { a_saved User, reference: "anna@example.com" }
    let(:supplier_1) { a_saved User, reference: "supplier1@example.com" }

    before do
      workflow.statuses.create name: "Incoming",
        reference: "incoming", position: 1,
        assign_to: [
          {if: "name == 'For Anna'", contact: "anna@example.com"},
          {contact: "nichola@example.com"}
        ],
        actions: [
          {reference: "place_order_with_supplier", name: "Place order with Supplier", primary: true, colour: "success",
           configuration: {
             fields: [{reference: "supplier", name: "Supplier", type: "StandardProcedure::FieldDefinition::Text"}],
             outcomes: [{type: "StandardProcedure::WorkflowAction::ChangeStatus", status: "dispatched"}]
           }},
          {reference: "make_priority", name: "Make this a priority order", type: "StandardProcedure::MakePriorityOrder"}
        ],
        alerts: [
          {if: "name == 'For Anna'", sender: "anna@example.com", hours: 24, type: "StandardProcedure::Alert::SendNotification", recipients: ["anna@example.com"]},
          {hours: 48, sender: "anna@example.com", type: "StandardProcedure::Alert::SendNotification", recipients: ["nichola@example.com"]}
        ]
      workflow.statuses.create name: "In progress", reference: "in_progress", position: 2
    end

    it "sets the default assignment on the document when it is added" do
      anna.touch
      nichola.touch

      subject.document_added document: document, performed_by: user
      expect(document.assigned_to).to eq nichola
    end

    it "sets the assignment based on the rules defined" do
      document.update name: "For Anna"
      anna.touch
      nichola.touch

      subject.document_added document: document, performed_by: user
      expect(document.assigned_to).to eq anna
    end

    it "knows which actions are available" do
      expect(subject.available_actions).to eq %w[place_order_with_supplier make_priority]
    end
    it "knows the names of the available actions" do
      expect(subject.name_for(:place_order_with_supplier)).to eq "Place order with Supplier"
      expect(subject.name_for(:make_priority)).to eq "Make this a priority order"
      expect { subject.name_for(:something_else) }.to raise_exception(StandardProcedure::WorkflowStatus::InvalidActionReference)
    end
    it "knows the primary action" do
      expect(subject.primary_action_reference).to eq "place_order_with_supplier"
      expect(subject.primary_action_colour).to eq "success"
    end
    it "builds an action" do
      expect(subject.build_action(:place_order_with_supplier).class.name).to eq "StandardProcedure::WorkflowAction::UserDefined"
      expect(subject.build_action(:make_priority).class.name).to eq "StandardProcedure::MakePriorityOrder"
      expect { subject.build_action(:something_else) }.to raise_exception(StandardProcedure::WorkflowStatus::InvalidActionReference)
    end
    it "performs an action via a ruby class" do
      Thing.class_eval do
        has_field :priority, default: "low"
      end
      action = subject.perform_action(action: "make_priority", document: document, escalation_reason: "It's urgent", performed_by: user)
      expect(action.escalation_reason).to eq "It's urgent"
      expect(action.document.priority).to eq "high"
    end
    it "performs a user-defined action" do
      expect_any_instance_of(StandardProcedure::WorkflowAction::UserDefined).to receive(:perform)
      subject.perform_action action: "place_order_with_supplier", document: document, performed_by: user
    end

    it "adds alerts to an document when it is added" do
      Timecop.freeze(Time.now) do
        anna.touch
        nichola.touch

        subject.document_added document: document, performed_by: user
        expect(document.alerts).to_not be_empty
        alert = document.alerts.first
        expect(alert.due_at.to_date).to eq(Date.today + 2)
        expect(alert.recipients).to include nichola
      end
    end

    it "adds conditional alerts to an document when it is added" do
      document.update name: "For Anna"
      Timecop.freeze(Time.now) do
        anna.touch
        nichola.touch

        subject.document_added document: document, performed_by: user
        expect(document.alerts).to_not be_empty
        alert = document.alerts.first
        expect(alert.due_at.to_date).to eq(Date.today + 1)
        expect(alert.recipients).to include anna
        alert = document.alerts.last
        expect(alert.due_at.to_date).to eq(Date.today + 2)
        expect(alert.recipients).to include nichola
      end
    end

    it "evaluates any data in the context of the action that triggered the change"

    it "deactivates any existing alerts when it is added" do
      anna.touch
      nichola.touch
      existing_alert = document.alerts.create! due_at: 2.days.from_now, sender: anna.reference, status: "active", recipients: [anna, nichola]

      subject.document_added document: document, performed_by: user

      existing_alert.reload
      expect(existing_alert).to be_inactive
    end
  end
end
