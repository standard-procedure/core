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
      contacts = Array.wrap(recipients).map { |r| item.find_contact_from(r) }
      message =
        contact.send_message(
          recipients: contacts,
          subject: subject,
          contents: contents.to_s,
          performed_by: user,
        )
      message.link_to item
    end

    def set_reminder
      item.add_alert type: "StandardProcedure::Alert::SendNotification",
                     due_at: reminder_after.hours.from_now,
                     message: "Follow up on sent message: #{subject}",
                     contacts: [contact],
                     performed_by: user
    end
  end
end
