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
      contacts =
        Array.wrap(recipients).map { |r| document.find_contact_from(r) }.compact
      message =
        contact.send_message(
          recipients: contacts,
          subject: subject,
          contents: contents.to_s,
          performed_by: performed_by
        )
      message.link_to document
    end

    def set_reminder
      document.add_alert type: "StandardProcedure::Alert::SendNotification",
        due_at: reminder_after.hours.from_now,
        message: "Follow up on sent message: #{subject}",
        contacts: [contact],
        performed_by: performed_by
    end
  end
end
