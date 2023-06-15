module StandardProcedure
  class WorkflowStatus::PerformActionJob < ApplicationJob
    def perform workflow_status, action:, document:, user:, **params
      params = params.merge(workflow_status.configuration_for(action).excluding(:name, :reference))
      workflow_status.action_handler_for(action).perform(params.merge(document: document, performed_by: user))
    end
  end
end
