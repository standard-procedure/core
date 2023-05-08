module StandardProcedure
  class WorkflowAction::SendMessage < WorkflowAction
    has_field :subject
    has_array :recipients
    has_rich_text :contents
    has_field :reminder_after

    def perform
      StandardProcedure::WorkflowAction::SendMessageJob.perform_now document, user: performed_by, subject: subject, contents: contents, recipients: recipients, reminder_after: reminder_after
    end
  end
end
