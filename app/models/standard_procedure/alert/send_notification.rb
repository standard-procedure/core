module StandardProcedure
  class Alert::SendNotification < Alert
    def perform
      contacts.each do |contact|
        contact.notifications.create!(message: self.message).tap do |notification|
          notification.link_to item
        end
      end
    end
  end
end
