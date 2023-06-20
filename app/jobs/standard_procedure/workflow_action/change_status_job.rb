module StandardProcedure
  class WorkflowAction::ChangeStatusJob < ApplicationJob
    def perform document, user:, status_reference:, action: nil
      status = document.workflow.status status_reference
      document.update status: status
      WorkflowStatus::DocumentAddedJob.perform_now status, document: document, user: user, action: action
    end
  end
end
