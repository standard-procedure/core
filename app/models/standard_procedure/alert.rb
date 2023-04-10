module StandardProcedure
  class Alert < ApplicationRecord
    scope :due_now, -> { due_on(Time.now) }
    scope :due_at, ->(time) { where(due_at: DateTime.beginning_of_time..time) }

    has_fields
    has_array :recipients
    belongs_to :item, polymorphic: true
    enum status: {active: 0, triggered: 100, inactive: 1000}
    validates :due_at, presence: true
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

    class << self
      def trigger_all
        due_now.find_each { |alert| alert.trigger }
      end
    end
  end
end
