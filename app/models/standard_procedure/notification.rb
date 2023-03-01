module StandardProcedure
  class Notification < ApplicationRecord
    belongs_to :contact, class_name: "StandardProcedure::Contact"
    enum notification_type: { standard: 0, urgent: 100 }
    has_linked :items
    has_rich_text :details
  end
end
