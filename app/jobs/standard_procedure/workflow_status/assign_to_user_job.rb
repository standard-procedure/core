module StandardProcedure
  class WorkflowStatus::AssignToUserJob < ApplicationJob
    def perform workflow_status, document:, user:
      assign_to = workflow_status.default_contact_for(document)
      return if assign_to.blank?
      document._workflow_assign_to assign_to
    end
  end
end
