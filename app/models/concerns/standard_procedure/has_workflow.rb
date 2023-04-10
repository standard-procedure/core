module StandardProcedure
  module HasWorkflow
    extend ActiveSupport::Concern

    class_methods do
      def has_alerts
        has_many :alerts, class_name: "StandardProcedure::Alert", dependent: :destroy, as: :alertable
      end

      def find_workflow_users_with method
        instance_eval do
          define_method :_workflow_find_user do |reference|
            reference.is_a?(String) ? send(method.to_sym, reference) : reference
          end
        end
      end
    end

    included do
      command :add_alert do |performed_by:, **params|
        alerts.create!(**params)
      end
    end
  end
end
