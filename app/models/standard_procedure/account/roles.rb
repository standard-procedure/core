module StandardProcedure
  class Account
    module Roles
      extend ActiveSupport::Concern

      included do
        has_many :roles, class_name: "StandardProcedure::Role", dependent: :destroy
      end

      protected

      def build_roles_from_configuration
        config_for(:roles).each do |role_data|
          next if roles.find_by(reference: role_data[:reference]).present?
          role = roles.create role_data.slice(:reference, :name, :plural, :access_level)
          Array.wrap(role_data[:fields]).each do |field_data|
            role.fields.where(reference: field_data[:reference]).first_or_create!(field_data)
          end
        end
      end
    end
  end
end
