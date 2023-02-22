module StandardProcedure
  class Account
    module Groups
      extend ActiveSupport::Concern

      included do
        has_many :groups, class_name: "StandardProcedure::Group", dependent: :destroy

        command :add_group, :remove_group
      end

      protected

      def build_groups_from_configuration
        build_configuration_for :groups, include_fields: true
      end
    end
  end
end
