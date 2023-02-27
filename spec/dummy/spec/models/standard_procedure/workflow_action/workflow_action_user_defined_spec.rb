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
      { reference: "some_action",
       name: "Do something",
       outcomes: [
        { type: "StandardProcedure::WorkflowAction::ChangeStatus",
          status: "stage_two" },
        { type: "StandardProcedure::WorkflowAction::SendNotification",
          recipients: ["contact"],
          message: "Here we go" },
      ] }
    end
    it "invokes the given outcomes" do
      stage_two.touch
      contact.touch

      expect(StandardProcedure::WorkflowAction::ChangeStatus).to receive(:create!)
      expect(StandardProcedure::WorkflowAction::SendNotification).to receive(:create!)

      WorkflowAction::UserDefined.create!(user: user, item: item, configuration: configuration)
    end
  end
end
