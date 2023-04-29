module StandardProcedure
  module HasMessages
    extend ActiveSupport::Concern

    included do
      is_linked_to :attached_messages, class_name: "StandardProcedure::Message"
    end

    class_methods do
      def has_messages
        has_many :sent_messages, class_name: "StandardProcedure::Message", dependent: :destroy, as: :sender
        has_many :received_messages, class_name: "StandardProcedure::MessageRecipient", dependent: :destroy, as: :recipient
        has_many :messages, through: :received_messages

      end
    end
  end
end
