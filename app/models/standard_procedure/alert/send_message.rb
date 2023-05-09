module StandardProcedure
  class Alert::SendMessage < Alert

    def perform
      Message::SendJob.perform_now subject: subject, user: user, contents: message, recipients: recipients, links: [self, alertable]
    end
  end
end
