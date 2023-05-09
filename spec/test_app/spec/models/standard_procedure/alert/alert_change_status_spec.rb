require "rails_helper"

module StandardProcedure
  RSpec.describe Alert::ChangeStatus, type: :model do
    let(:document) { a_saved Thing }
    let(:workflow) { a_saved Workflow }
    let(:stage_one) { a_saved WorkflowStatus, reference: "stage_one", workflow: workflow, position: 1 }
    let(:stage_two) { a_saved WorkflowStatus, reference: "stage_two", workflow: workflow, position: 2 }
    let(:alice) { a_saved User }
    let(:bob) { a_saved User }
    let(:chris) { a_saved User }

    it "changes the status of the document" do
      [alice, bob, chris, stage_one, stage_two].each(&:touch)

      document.update status: stage_one

      alert = Alert::ChangeStatus.create! alertable: document, sender: "chris", due_at: 1.minute.ago, status: "active", status_reference: "stage_two"
      alert.trigger

      expect(document.reload.status).to eq stage_two
    end
  end
end
