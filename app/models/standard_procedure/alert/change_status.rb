module StandardProcedure
  class Alert::ChangeStatus < Alert
    has_field :status_reference
    def perform
      WorkflowAction::ChangeStatusJob.perform_now alertable, user: user, status_reference: status_reference
    end
  end
end
