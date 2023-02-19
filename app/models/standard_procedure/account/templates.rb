module StandardProcedure
  class Account
    module Templates
      extend ActiveSupport::Concern

      included do
        has_many :templates, -> { order :name }, class_name: "StandardProcedure::WorkflowItemTemplate", dependent: :destroy
        has_many :items, -> { order :position }, through: :templates
      end

      protected

      def build_templates_from_configuration
        build_configuration_for :templates, include_fields: true
      end
    end
  end
end