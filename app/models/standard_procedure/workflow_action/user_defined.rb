module StandardProcedure
  class WorkflowAction::UserDefined < WorkflowAction
    has_field_definitions

    def perform
      Array.wrap(configuration[:outcomes]).each { |outcome_params| perform_outcome_from outcome_params }
    end

    def perform_outcome_from(configuration)
      class_name = configuration.delete(:type)
      configuration[:status] = workflow.status(configuration[:status])
      class_name.constantize.perform configuration.merge(performed_by: performed_by, document: document, configuration: configuration)
    end

    def prepare
      load_field_definitions
      with_fields_from self
    end
  end
end
