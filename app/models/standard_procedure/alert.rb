module StandardProcedure
  class Alert < ApplicationRecord
    scope :due_now, -> { due_on(Time.now) }
    scope :due_at, ->(time) { where(due_at: (time - 30.minutes)..(time + 30.minutes)) }
    belongs_to :item, polymorphic: true
    has_and_belongs_to_many :contacts, class_name: "StandardProcedure::Contact", foreign_key: "standard_procedure_alert_id", association_foreign_key: "standard_procedure_contact_id"
    enum status: { waiting: 0, active: 100, acknowledged: 200, inactive: 1000 }
    validates :due_at, presence: true
  end
end
