module StandardProcedure
  class Account
    module Workflows
      extend ActiveSupport::Concern

      included do
        has_many :workflows, class_name: "StandardProcedure::Workflow", dependent: :destroy
        has_many :statuses, -> { order :position }, through: :workflows
        has_many :items, -> { order :position }, through: :statuses
      end

      protected

      def build_workflows_from_configuration
        build_configuration_for :workflows, params: [:reference, :name, :type] do |workflow, configuration|
          build_configuration_for :statuses, params: [:reference, :name, :type], target: workflow, configuration: configuration[:statuses]
        end
      end
    end
  end
end