module StandardProcedure
  class Notification < ApplicationRecord
    has_linked :items
    belongs_to :contact, class_name: "StandardProcedure::Contact"
    enum notification_type: { standard: 0, urgent: 100 }
  end
end
