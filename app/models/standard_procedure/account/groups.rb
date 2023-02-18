module StandardProcedure
  class Account
    module Groups
      extend ActiveSupport::Concern

      included do
        has_many :groups, class_name: "StandardProcedure::Group", dependent: :destroy
        has_many :contacts, -> { order :name }, through: :groups
      end

      protected

      def build_groups_from_configuration
        build_configuration_for :groups, include_fields: true
      end
    end
  end
end
