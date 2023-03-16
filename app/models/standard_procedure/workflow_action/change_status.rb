module StandardProcedure
  class WorkflowAction::ChangeStatus < WorkflowAction
    has_model :status, "StandardProcedure::WorkflowStatus"
    validates :status, presence: true

    def perform
      update_status
    end

    def update_status
      document.update status: status
      status.document_added(document: document, performed_by: performed_by)
    end
  end
end
