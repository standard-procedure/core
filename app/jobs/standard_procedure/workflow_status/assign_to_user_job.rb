module StandardProcedure
  class WorkflowStatus::AssignToUserJob < ApplicationJob
    def perform workflow_status, document:, user:, assign_to: nil
      assign_to ||= workflow_status.default_contact_for(document)
      return if assign_to.blank?
      document._workflow_assign_to assign_to
      # TODO: This is app-specific
      Notification::SendJob.perform_now recipient: assign_to, details: I18n.t("workflow_status.assign_to_user.item_assigned_to_you"), links: [document, document.account]
    end
  end
end
