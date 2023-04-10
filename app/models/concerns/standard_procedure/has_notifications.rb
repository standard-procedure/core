module StandardProcedure
  module HasNotifications
    extend ActiveSupport::Concern

    class_methods do
      def has_notifications
        has_many :notifications, class_name: "StandardProcedure::Notification", dependent: :destroy, as: :recipient
      end
    end
  end
end
