module StandardProcedure
  module HasMessages
    extend ActiveSupport::Concern

    class_methods do
      def has_messages
        has_many :sent_messages, class_name: "StandardProcedure::Message", dependent: :destroy, as: :sender
        has_many :received_messages, class_name: "StandardProcedure::MessageRecipient", dependent: :destroy, as: :recipient
        has_many :messages, through: :received_messages

        command :send_message do |subject:, performed_by:, contents: "", recipients: []|
          Message.create!(sender: self, subject: subject, contents: contents).tap do |message|
            recipients.each do |recipient|
              message.message_recipients.create! recipient: recipient
              notification = recipient.notifications.create! details: contents, type: "StandardProcedure::Notification::MessageReceived"
              notification.link_to message
            end
          end
        end
      end
    end
  end
end
