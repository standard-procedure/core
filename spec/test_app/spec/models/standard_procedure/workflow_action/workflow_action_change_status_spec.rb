require "rails_helper"

module StandardProcedure
  RSpec.describe WorkflowAction::ChangeStatus, type: :model do
    let(:document) { a_saved_document_titled "Something" }
    let(:stage_one) { document.status }
    let(:stage_two) do
      a_saved WorkflowStatus,
        reference: "stage_two",
        workflow: workflow,
        position: 2
    end
    let(:workflow) { stage_one.workflow }
    let(:account) { workflow.account }
    let(:contact) do
      a_saved_contact_called "Someone", account: account, user: user
    end
    let(:user) { a_saved ::User }
    let(:configuration) do
      {
        reference: "move_forward",
        name: "Move forward",
        type: "StandardProcedure::WorkflowAction::ChangeStatus",
        status: "stage_two"
      }
    end
    it "changes the status of the given document" do
      stage_two.touch

      # have to use `expect_any_instance_of` as the actual status is going to be loaded dynamically so we don't
      # know which actual status-instance will receive the message
      expect_any_instance_of(StandardProcedure::WorkflowStatus).to receive(
        :document_added
      ).with(performed_by: user, document: document)
      WorkflowAction::ChangeStatus.perform(
        document: document,
        configuration: configuration,
        status: stage_two,
        performed_by: user
      )
    end
  end
end
