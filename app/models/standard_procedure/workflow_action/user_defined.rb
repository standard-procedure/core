module StandardProcedure
  class WorkflowAction::UserDefined < WorkflowAction
    def perform
      perform_outcomes
    end

    def perform_outcomes
      Array.wrap(configuration[:outcomes]).each do |outcome_params|
        perform_outcome_from outcome_params
      end
    end

    def perform_outcome_from(configuration)
      class_name = configuration.delete(:type)
      configuration[:status] = workflow.statuses.find_by(reference: configuration[:status]) if configuration[:status].is_a? String
      class_name.constantize.perform configuration.merge(user: user, item: item, configuration: configuration)
    end
  end
end
