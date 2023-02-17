module StandardProcedure
  class Account
    module Roles
      extend ActiveSupport::Concern

      def roles
        @roles ||= system_roles + configured_roles
      end

      protected

      def system_roles
        @system_roles ||= ["admin", "restricted"].freeze
      end

      def configured_roles
        @configured_roles ||= config_for(:roles)
      end
    end
  end
end
