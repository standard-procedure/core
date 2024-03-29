require "rails_helper"

module StandardProcedure
  RSpec.describe WorkflowAction::UserDefined, type: :model do
    let(:account) { a_saved Category }
    let(:document) { a_saved Thing, status: stage_one }

    let(:user) { a_saved User }
    let(:workflow) { a_saved Workflow, account: account }

    let(:stage_one) { a_saved WorkflowStatus, reference: "stage_one", workflow: workflow, position: 1 }
    let(:stage_two) { a_saved WorkflowStatus, reference: "stage_two", workflow: workflow, position: 2 }

    let(:configuration) do
      {
        fields: [
          {
            reference: "extra_information",
            name: "Extra Information",
            type: "StandardProcedure::FieldDefinition::RichText"
          },
          {
            reference: "price",
            name: "Price",
            type: "StandardProcedure::FieldDefinition::Currency"
          }

        ],
        outcomes: [
          {
            type: "StandardProcedure::WorkflowAction::ChangeStatusJob",
            status_reference: "stage_two"
          },
          {
            type: "StandardProcedure::WorkflowAction::SendMessageJob",
            recipients: ["contact"],
            subject: "Things",
            contents: "Here we go",
            reminder_after: 24
          }
        ]

      }
    end

    before do
      stage_one.touch
      stage_two.touch
    end

    it "builds and assigns user-defined fields" do
      action = WorkflowAction::UserDefined.prepare_from(configuration)
      field_definition = action.field_definitions.first
      expect(field_definition.reference).to eq "extra_information"
      expect(field_definition.name).to eq "Extra Information"
      expect(field_definition.model_name.to_s).to eq "StandardProcedure::FieldDefinition::RichText"
      expect(action).to respond_to(:extra_information)

      field_definition = action.field_definitions.last
      expect(field_definition.reference).to eq "price"
      expect(field_definition.name).to eq "Price"
      expect(field_definition.model_name.to_s).to eq "StandardProcedure::FieldDefinition::Currency"
      expect(action).to respond_to(:price)
    end

    it "updates the document and performs the outcomes" do
      expect(StandardProcedure::UpdateJob).to receive(:perform_now).with(document, user: user, extra_information: "Something", price: 22.50)

      expect(StandardProcedure::WorkflowAction::ChangeStatusJob).to receive(:perform_now).with(document, user: user, status_reference: "stage_two")

      expect(StandardProcedure::WorkflowAction::SendMessageJob).to receive(:perform_now).with(document, user: user, subject: "Things", contents: "Here we go", recipients: ["contact"], reminder_after: 24)

      WorkflowAction::UserDefined.perform(performed_by: user, document: document, configuration: configuration, extra_information: "Something", price: 22.50)
    end
  end
end
