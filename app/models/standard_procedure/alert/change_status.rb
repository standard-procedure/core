module StandardProcedure
  class Alert::ChangeStatus < Alert
    def perform
      WorkflowAction::ChangeStatusJob.perform_now alertable, user: user, status_reference: status_reference
    end
  end
end
