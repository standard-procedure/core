module StandardProcedure
  class MessageRecipient < ApplicationRecord
    scope :unread, -> { where(read_at: nil) }
    scope :read, -> { where.not(read_at: nil) }

    belongs_to :message, class_name: "StandardProcedure::Message"
    belongs_to :recipient, class_name: "StandardProcedure::Contact"
  end
end
