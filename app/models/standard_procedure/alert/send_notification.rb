module StandardProcedure
  class Alert::SendNotification < Alert
    def perform
      WorkflowAction::SendNotificationJob.perform_now alertable, user: user, recipients: recipients, message: message, links: [self, alertable]
    end
  end
end
