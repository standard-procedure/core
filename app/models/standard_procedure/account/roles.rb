module StandardProcedure
  class Account
    module Roles
      extend ActiveSupport::Concern

      included do
        has_many :roles,
                 class_name: "StandardProcedure::Role",
                 dependent: :destroy
        command :add_role, :remove_role
      end

      def contacts
        Contact.where(account: self)
      end

      protected

      def build_roles_from_configuration
        build_configuration_for :roles,
                                include_fields: true,
                                params: %i[reference name plural access_level]
      end
    end
  end
end
