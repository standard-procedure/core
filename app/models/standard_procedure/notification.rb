module StandardProcedure
  class Notification < ApplicationRecord
    scope :unacknowledged, -> { where(acknowledged_at: nil) }
    belongs_to :recipient, polymorphic: true
    enum notification_type: {standard: 0, urgent: 100}
    has_linked :items
    has_rich_text :details

    def to_s
      @name ||= details.to_plain_text.strip.split("\n").first
    end
  end
end
