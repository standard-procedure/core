module StandardProcedure
  class Account
    module Roles
      extend ActiveSupport::Concern

      included do
        has_many :roles, class_name: "StandardProcedure::Role", dependent: :destroy
      end

      protected

      def build_roles_from_configuration
        build_configuration_for :roles, include_fields: true, params: [:reference, :name, :plural, :access_level]
      end
    end
  end
end
