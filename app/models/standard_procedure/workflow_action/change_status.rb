module StandardProcedure
  class WorkflowAction::ChangeStatus < WorkflowAction
    has_model :new_status, "StandardProcedure::WorkflowStatus"
    validates :new_status, presence: true

    def perform
      WorkflowAction::ChangeStatusJob.perform_now document, user: performed_by, status: new_status
    end
  end
end
