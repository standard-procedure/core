module StandardProcedure
  class WorkflowAction::SendMessage < WorkflowAction
    has_field :subject
    has_array :recipients
    has_rich_text :contents
    has_field :reminder_after

    def perform
      send_message
      set_reminder if reminder_after.present?
    end

    def send_message
      people = Array.wrap(recipients).map { |r| document._workflow_find_user(r) }.compact
      Message::SendJob.perform_now subject: subject, user: performed_by, contents: contents.to_s, recipients: people, links: document
    end

    def set_reminder
      AddRecordJob.perform_now document, :alerts, user: performed_by, type: "StandardProcedure::Alert::SendNotification", due_at: reminder_after.hours.from_now, message: "Follow up on sent message: #{subject}", recipients: [user]
    end
  end
end
