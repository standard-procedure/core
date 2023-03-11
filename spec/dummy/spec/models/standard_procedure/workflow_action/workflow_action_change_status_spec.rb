require "rails_helper"

module StandardProcedure
  RSpec.describe WorkflowAction::ChangeStatus, type: :model do
    let(:item) { a_saved_item_titled "Something" }
    let(:stage_one) { item.status }
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
        status: "stage_two",
      }
    end
    it "changes the status of the given item" do
      stage_two.touch
      contact.touch

      # have to use `expect_any_instance_of` as the actual status is going to be loaded dynamically so we don't
      # know which actual status-instance will receive the message
      expect_any_instance_of(StandardProcedure::WorkflowStatus).to receive(
        :item_added,
      ).with(performed_by: user, item: item)
      WorkflowAction::ChangeStatus.perform(
        item: item,
        configuration: configuration,
        status: stage_two,
        performed_by: user,
      )
    end
  end
end
