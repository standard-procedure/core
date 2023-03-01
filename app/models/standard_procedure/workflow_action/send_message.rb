module StandardProcedure
  class WorkflowAction::SendMessage < WorkflowAction
    has_field :subject
    has_array :recipients
    has_rich_text :contents
    has_field :reminder_after

    def perform
      contacts = Array.wrap(recipients).map { |r| item.find_contact_from(r) }
      contact.send_message(user, recipients: contacts, subject: subject, contents: contents.to_s).tap do |message|
        message.link_to item
        item.add_alert user, type: "StandardProcedure::Alert::SendNotification", due_at: reminder_after.hours.from_now, message: "Follow up on sent message: #{subject}", contacts: [contact] unless reminder_after.blank?
      end
    end
  end
end
