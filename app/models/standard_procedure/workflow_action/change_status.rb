module StandardProcedure
  class WorkflowAction::ChangeStatus < WorkflowAction
    has_model :status, "StandardProcedure::WorkflowStatus"
    validates :status, presence: true

    def perform
      WorkflowAction::ChangeStatusJob.perform_now document, user: performed_by, status: status
    end
  end
end
