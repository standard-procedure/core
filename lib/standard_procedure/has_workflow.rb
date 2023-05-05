module StandardProcedure
  module HasWorkflow
    extend ActiveSupport::Concern

    class_methods do
      def has_workflow foreign_key: "status_id", optional: false
        belongs_to :status, class_name: "StandardProcedure::WorkflowStatus", foreign_key: foreign_key, optional: optional

        define_method :available_actions do
          Array.wrap(status&.available_actions)
        end

        define_method :perform_action do |action: nil, document: nil, performed_by: nil, **params|
          return nil if status.blank?
          raise StandardProcedure::WorkflowStatus::MissingConfiguration.new("find_user is not defined") unless respond_to? :_workflow_find_user
          raise StandardProcedure::WorkflowStatus::MissingConfiguration.new("assign_to is not defined") unless respond_to? :_workflow_assign_to
        end
      end

      def has_alerts
        has_many :alerts, class_name: "StandardProcedure::Alert", dependent: :destroy, as: :alertable

        define_method :add_alert do |performed_by:, **params|
          alerts.create!(**params)
        end
      end

      def find_user &block
        instance_eval do
          define_method :_workflow_find_user, &block
        end
      end

      def assign_to &block
        instance_eval do
          define_method :_workflow_assign_to, &block
        end
      end
    end
  end
end
