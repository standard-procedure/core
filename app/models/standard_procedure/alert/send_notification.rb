module StandardProcedure
  class Alert::SendNotification < Alert
    def perform
      contacts.each do |contact|
        contact
          .notifications
          .create!(details: message)
          .tap { |notification| notification.link_to item }
      end
    end
  end
end
