module StandardProcedure
  class Alert < ApplicationRecord
    scope :due_now, -> { due_on(Time.now) }
    scope :due_at, ->(time) { where(due_at: ..time) }

    has_fields
    has_array :recipients
    has_field :sender
    has_field :status_reference
    has_field :subject
    belongs_to :alertable, polymorphic: true
    enum status: {active: 0, triggered: 100, inactive: 1000}
    validates :due_at, presence: true
    validates :sender, presence: true
    has_rich_text :message

    def due?
      active? && (due_at <= Time.current)
    end

    def trigger(force: false)
      return unless due? || force
      perform
      triggered!
    end

    def perform
      raise "Not yet implemented"
    end

    def subject
      message.to_plain_text.strip.split("\n").first
    end

    def user
      alertable._workflow_find_user(sender)
    end

    class << self
      def trigger_all
        due_now.find_each { |alert| alert.trigger }
      end
    end
  end
end
