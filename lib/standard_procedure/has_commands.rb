module StandardProcedure
  module HasCommands
    extend ActiveSupport::Concern

    included do
      is_linked_to :commands, class_name: "StandardProcedure::Command", intermediary_class_name: "StandardProcedure::CommandLink"
    end

    def available_commands
      []
    end

    def available_commands_for user
      []
    end

    class_methods do
      def is_user
        has_many :performed_commands, class_name: "StandardProcedure::Command", as: :user, dependent: :destroy
        has_many :notifications, class_name: "StandardProcedure::Notification", as: :user, dependent: :destroy
      end
    end
  end
end
