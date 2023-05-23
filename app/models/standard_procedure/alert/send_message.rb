module StandardProcedure
  class Alert::SendMessage < Alert
    def perform
      contents = alertable._evaluate_contents message
      WorkflowAction::SendMessageJob.perform_now alertable, user: user, recipients: recipients, subject: subject, contents: contents, links: [self, alertable]
    end
  end
end
