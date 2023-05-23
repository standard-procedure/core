module StandardProcedure
  class WorkflowAction::SendNotificationJob < ApplicationJob
    def perform document, user:, recipients: [], message: "", links: [], reminder_after: nil
      people = Array.wrap(recipients).map { |r| document._workflow_find_user(r) }.compact

      people.each do |reference|
        recipient = document._workflow_find_user reference
        Notification::SendJob.perform_later recipient: recipient, details: message, links: links, type: "StandardProcedure::Notification::AlertReceived"
      end

      AddRecordJob.perform_now document, :alerts, user: performed_by, type: "StandardProcedure::Alert::SendNotification", due_at: reminder_after.hours.from_now, message: "Follow up on sent message: #{subject}", recipients: [user] if reminder_after.present?
    end
  end
end
