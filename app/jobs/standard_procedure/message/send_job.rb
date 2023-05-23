module StandardProcedure
  class Message::SendJob < ApplicationJob
    def perform subject:, user:, contents: "", recipients: [], links: []
      links = Array.wrap links
      recipients = Array.wrap recipients
      Message.create!(sender: user, subject: subject, contents: contents).tap do |message|
        links.each { |link| message.link_to link }
        recipients.each do |recipient|
          message.message_recipients.create! recipient: recipient
          Notification::SendJob.perform_now recipient: recipient, details: contents, type: "StandardProcedure::Notification::MessageReceived", links: links + [message]
        end
      end
    end
  end
end
