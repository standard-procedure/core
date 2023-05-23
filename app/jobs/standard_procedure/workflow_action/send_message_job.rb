module StandardProcedure
  class WorkflowAction::SendMessageJob < ApplicationJob
    def perform document, user:, subject: "", recipients: [], contents: "", links: [], reminder_after: nil
      people = Array.wrap(recipients).map { |r| document._workflow_find_user(r) }.compact

      Message::SendJob.perform_now subject: subject, user: user, contents: contents.to_s, recipients: people, links: links

      AddRecordJob.perform_now document, :alerts, user: user, type: "StandardProcedure::Alert::SendNotification", due_at: reminder_after.hours.from_now, message: "Follow up on sent message: #{subject}", recipients: [user] if reminder_after.present?
    end
  end
end
