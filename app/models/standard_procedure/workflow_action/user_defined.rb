module StandardProcedure
  class WorkflowAction::UserDefined < WorkflowAction

    def perform
      Array.wrap(configuration[:outcomes]).each { |outcome_params| perform_outcome_from outcome_params }
    end

    def perform_outcome_from(configuration)
      class_name = configuration.delete(:type)

      class_name.constantize.perform_now document, user: performed_by, **configuration
      document
    end
  end
end
