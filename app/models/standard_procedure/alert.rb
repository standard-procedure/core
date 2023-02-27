module StandardProcedure
  class Alert < ApplicationRecord
    has_fields

    scope :due_now, -> { due_on(Time.now) }
    scope :due_at, ->(time) { where(due_at: DateTime.beginning_of_time..time) }

    belongs_to :item, polymorphic: true
    has_and_belongs_to_many :contacts, class_name: "StandardProcedure::Contact", foreign_key: "standard_procedure_alert_id", association_foreign_key: "standard_procedure_contact_id"
    enum status: { active: 0, triggered: 100, acknowledged: 200, inactive: 1000 }
    validates :due_at, presence: true

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
  end
end
