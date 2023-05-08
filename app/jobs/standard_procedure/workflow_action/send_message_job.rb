module StandardProcedure
  class WorkflowAction::SendMessageJob < ApplicationJob
    def perform document, user:, subject: "", recipients: [], contents: "", reminder_after: nil
      people = Array.wrap(recipients).map { |r| document._workflow_find_user(r) }.compact

      Message::SendJob.perform_now subject: subject, user: performed_by, contents: contents.to_s, recipients: people, links: document

      AddRecordJob.perform_now document, :alerts, user: performed_by, type: "StandardProcedure::Alert::SendNotification", due_at: reminder_after.hours.from_now, message: "Follow up on sent message: #{subject}", recipients: [user] if reminder_after.present?
    end
  end
end
