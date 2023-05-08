module StandardProcedure
  class WorkflowAction::ChangeStatusJob < ApplicationJob
    def perform document, user:, status_reference:
      status = document.workflow.status status_reference
      document.update status: status
      status.document_added(document: document, performed_by: user)
    end
  end
end
