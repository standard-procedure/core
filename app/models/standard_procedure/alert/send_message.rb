module StandardProcedure
  class Alert::SendMessage < Alert
    def perform
      users = recipients.map { |reference| alertable._workflow_find_user(reference) }
      Message::SendJob.perform_now subject: subject, user: user, contents: message, recipients: users, links: [self, alertable]
    end
  end
end
