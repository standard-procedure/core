module StandardProcedure
  class WorkflowStatus::AssignToUserJob < ApplicationJob
    def perform workflow_status, document:, user:
      assign_to = workflow_status.default_contact_for(document)
      return if assign_to.blank?
      document._workflow_assign_to assign_to
      Notification::SendJob.perform_now recipient: assign_to, details: I18n.t(".item_assigned_to_you"), links: [document]
    end
  end
end