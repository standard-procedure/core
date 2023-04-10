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
        reference: "some_action",
        name: "Do something",
        fields: [
          {
            reference: "extra_information",
            name: "Extra Information",
            type: "StandardProcedure::FieldDefinition::RichText"
          }
        ],
        outcomes: [
          {
            type: "StandardProcedure::WorkflowAction::ChangeStatus",
            status: "stage_two"
          },
          {
            type: "StandardProcedure::WorkflowAction::SendMessage",
            recipients: ["contact"],
            message: "Here we go"
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
    end

    it "invokes the given outcomes" do
      change_status = spy("StandardProcedure::WorkflowAction::ChangeStatus")
      expect(StandardProcedure::WorkflowAction::ChangeStatus).to receive(:prepare_from).and_return(change_status)
      expect(change_status).to receive(:perform)
      send_message = spy("StandardProcedure::WorkflowAction::SendMessage")
      expect(StandardProcedure::WorkflowAction::SendMessage).to receive(:prepare_from).and_return(send_message)
      expect(send_message).to receive(:perform)

      WorkflowAction::UserDefined.perform(performed_by: user, document: document, configuration: configuration)
    end
  end
end
