require "rails_helper"

module StandardProcedure
  RSpec.describe WorkflowAction::UserDefined, type: :model do
    let(:item) { a_saved_item_titled "Something" }
    let(:stage_one) { item.status }
    let(:stage_two) { a_saved WorkflowStatus, reference: "stage_two", workflow: workflow, position: 2 }
    let(:workflow) { stage_one.workflow }
    let(:account) { workflow.account }
    let(:contact) { a_saved_contact_called "Someone", account: account, user: user }
    let(:user) { a_saved ::User }
    let(:configuration) do
      {
        reference: "some_action",
        name: "Do something",
        fields: [
          { reference: "extra_information",
            name: "Extra Information",
            type: "StandardProcedure::FieldDefinition::RichText" },
        ],
        outcomes: [
          { type: "StandardProcedure::WorkflowAction::ChangeStatus",
            status: "stage_two" },
          { type: "StandardProcedure::WorkflowAction::SendNotification",
            recipients: ["contact"],
            message: "Here we go" },
        ],
      }
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
      stage_two.touch
      contact.touch

      change_status = spy("StandardProcedure::WorkflowAction::ChangeStatus")
      expect(StandardProcedure::WorkflowAction::ChangeStatus).to receive(:prepare_from).and_return(change_status)
      expect(change_status).to receive(:perform)
      send_notification = spy("StandardProcedure::WorkflowAction::SendNotification")
      expect(StandardProcedure::WorkflowAction::SendNotification).to receive(:prepare_from).and_return(send_notification)
      expect(send_notification).to receive(:perform)

      WorkflowAction::UserDefined.perform(user: user, item: item, configuration: configuration)
    end
  end
end
