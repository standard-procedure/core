module StandardProcedure
  class Alert::SendNotification < Alert
    def perform
      recipients.each do |recipient|
        recipient.notifications.create!(details: message).tap { |notification| notification.link_to alertable }
      end
    end
  end
end
