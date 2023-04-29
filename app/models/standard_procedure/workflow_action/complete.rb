module StandardProcedure
  class WorkflowAction::Complete < WorkflowAction
    def perform
      WorkflowAction::CompleteJob.perform_now item, user: performed_by
    end
  end
end
