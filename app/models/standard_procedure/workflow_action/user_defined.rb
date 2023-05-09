module StandardProcedure
  class WorkflowAction::UserDefined < WorkflowAction
    def perform
      update_document
      perform_outcomes
    end

    def update_document
      params = {}
      field_definitions.each do |field_definition|
        params[field_definition.reader] = send(field_definition.reader)
      end
      StandardProcedure::UpdateJob.perform_now document, user: user, **params unless params.empty?
    end

    def perform_outcomes
      Array.wrap(configuration[:outcomes]).each { |outcome_params| perform_outcome_from outcome_params }
    end

    def perform_outcome_from(configuration)
      class_name = configuration.delete(:type)

      class_name.constantize.perform_now document, user: performed_by, **configuration
      document
    end
  end
end
