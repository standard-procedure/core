module StandardProcedure
  class Alert::SendNotification < Alert
    def perform
      recipients.each do |recipient|
        Notification::SendJob.perform_now recipient: recipient, details: message, links: [self, alertable], type: "StandardProcedure::Notification::AlertReceived"
      end
    end
  end
end
