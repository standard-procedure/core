module StandardProcedure
  class Alert < ApplicationRecord
    scope :due_today, -> { due_on(Date.today) }
    scope :due_on, ->(date) { where(trigger_at: date.to_date..(date.to_date + 1)) }
    belongs_to :item, polymorphic: true
    has_and_belongs_to_many :contacts, class_name: "StandardProcedure::Contact"
    enum status: { waiting: 0, active: 100, acknowledged: 200, inactive: 1000 }
    validates :due_at, presence: true
  end
end
