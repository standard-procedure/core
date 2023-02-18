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
        config_for(:workflows).each do |workflow_data|
          next if workflows.find_by(reference: workflow_data[:reference]).present?
          workflows.create workflow_data.slice(:reference, :name, :type)
        end
      end
    end
  end
end
