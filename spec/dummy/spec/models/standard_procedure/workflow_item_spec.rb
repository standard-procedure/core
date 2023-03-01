require "rails_helper"

module StandardProcedure
  RSpec.describe WorkflowItem, type: :model do
    subject { a_saved StandardProcedure::WorkflowItem, group: employees, status: incoming_status, template: template, name: "Something" }
    let(:user) { a_saved ::User }
    let(:account) { a_saved(Account).configure_from(configuration) }
    let(:template) { account.templates.find_by reference: "order" }
    let(:workflow) { account.workflows.find_by reference: "order_processing" }
    let(:incoming_status) { workflow.statuses.find_by reference: "incoming" }
    let(:in_progress_status) { workflow.statuses.find_by reference: "in_progress" }
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
            fields:
              - reference: supervisor 
                name: Supervisor
                type: StandardProcedure::FieldDefinition::Model
                model_type: StandardProcedure::Contact
        workflows:
          - reference: order_processing
            name: Order Processeing
            statuses:
              - reference: incoming
                name: Incoming
                position: 1
                assign_to: 
                  - contact: nichola@example.com
              - reference: in_progress
                name: In Progress
                position: 2
      YAML
    end

    before do
      anna.touch
      nichola.touch
    end

    it "assigns the item to a contact and notifies them" do
      subject.assign_to user, contact: nichola
      expect(subject.assigned_to).to eq nichola
      notification = nichola.notifications.last
      expect(notification).to_not be_nil
      expect(notification.linked_to? subject).to eq true
    end

    describe "changing status" do
      it "is updated" do
        subject.set_status user, reference: "in_progress"
        expect(subject.status).to eq in_progress_status
      end

      it "notifies the status that this item has been updated" do
        expect(in_progress_status).to receive(:item_added).with(user, item: subject)
        subject.set_status user, status: in_progress_status
      end
    end

    describe "finding contacts" do
      it "returns the given contact" do
        expect(subject.find_contact_from(nichola)).to eq nichola
      end
      it "finds contacts by reference" do
        expect(subject.find_contact_from("nichola@example.com")).to eq nichola
      end
      it "finds the item's contact" do
        subject.update contact: nichola
        expect(subject.find_contact_from("contact")).to eq nichola
      end
      it "finds contacts by referencing a custom field" do
        subject.with_fields_from(template.field_definitions).update contact: nichola, supervisor: anna
        expect(subject.find_contact_from("supervisor")).to eq anna
      end
    end
  end
end
