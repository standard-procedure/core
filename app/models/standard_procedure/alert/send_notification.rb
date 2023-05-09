module StandardProcedure
  class Alert::SendNotification < Alert
    def perform
      recipients.each do |reference|
        recipient = alertable._workflow_find_user reference
        Notification::SendJob.perform_now recipient: recipient, details: message, links: [self, alertable], type: "StandardProcedure::Notification::AlertReceived"
      end
    end
  end
end
