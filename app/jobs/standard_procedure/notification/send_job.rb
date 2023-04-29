module StandardProcedure
  class Notification::SendJob < ApplicationJob
    def perform recipient:, details:, links: [], type: "StandardProcedure::Notification"
      notification = recipient.notifications.create! details: details, type: type
      Array.wrap(links).each { |link| notification.link_to link }
    end
  end
end
