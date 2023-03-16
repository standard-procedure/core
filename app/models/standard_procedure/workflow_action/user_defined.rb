module StandardProcedure
  class WorkflowAction::UserDefined < WorkflowAction
    has_field_definitions

    def perform
      perform_outcomes
    end

    def perform_outcomes
      Array
        .wrap(configuration[:outcomes])
        .each { |outcome_params| perform_outcome_from outcome_params }
    end

    def perform_outcome_from(configuration)
      class_name = configuration.delete(:type)
      if configuration[:status].is_a? String
        configuration[:status] = workflow.statuses.find_by(
          reference: configuration[:status]
        )
      end
      class_name.constantize.perform configuration.merge(
        performed_by: performed_by,
        document: document,
        configuration: configuration
      )
    end

    def prepare
      load_field_definitions
      with_fields_from field_definitions
    end
  end
end
