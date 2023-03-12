module StandardProcedure
  class Account
    module Organisations
      extend ActiveSupport::Concern

      def organisations
        Organisation.where(account: self)
      end

      protected

      def build_groups_from_configuration
        build_configuration_for :organisations, include_fields: true
      end
    end
  end
end
