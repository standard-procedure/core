module StandardProcedure
  class WorkflowAction::UserDefined < WorkflowAction
    def perform
      perform_outcomes
    end

    def perform_outcomes
      configuration[:outcomes].each do |outcome_params|
        perform_outcome_from outcome_params
      end
    end

    def perform_outcome_from(params)
      class_name = params.delete(:type)
      params[:status] = workflow.statuses.find_by(reference: params[:status]) if params[:status].is_a? String
      class_name.constantize.create! params.merge(user: user, item: item, configuration: params)
    end
  end
end
