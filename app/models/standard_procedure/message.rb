module StandardProcedure
  class Message < ApplicationRecord
    belongs_to :sender, polymorphic: true
    has_many :message_recipients, -> { order :read_at }, class_name: "StandardProcedure::MessageRecipient", dependent: :destroy
    has_rich_text :contents
    has_linked :items

    validates :subject, presence: true

    def recipients
      message_recipients.collect(&:recipient)
    end
  end
end
