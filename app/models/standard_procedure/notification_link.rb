module StandardProcedure
  class NotificationLink < ApplicationRecord
    belongs_to :notification, class_name: "StandardProcedure::Notification"
    belongs_to :item, polymorphic: true
  end
end
