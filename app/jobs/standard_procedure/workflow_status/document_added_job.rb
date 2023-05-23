module StandardProcedure
  class WorkflowStatus::DocumentAddedJob < ApplicationJob
    def perform workflow_status, document:, user:, action: nil
      document.alerts.each do |existing_alert|
        StandardProcedure::UpdateJob.perform_now existing_alert, user: user, status: "inactive"
      end
      StandardProcedure::WorkflowStatus::AssignToUserJob.perform_now workflow_status, document: document, user: user

      workflow_status.alerts.each do |alert_data|
        alert_data.symbolize_keys!
        #  Only add this alert if it meets any "if" clauses in the definition
        next unless workflow_status.evaluate(alert_data, document)
        recipients = Array.wrap(alert_data[:recipients])
        message = action.nil? ? alert_data[:message] : action.evaluate_contents(alert_data[:message])
        hours = alert_data[:hours].hours
        StandardProcedure::AddRecordJob.perform_now document, :alerts, type: alert_data[:type], sender: alert_data[:sender], due_at: hours.from_now, subject: alert_data[:subject], message: message, status_reference: alert_data[:status_reference], recipients: recipients, user: user
      end
    end
  end
end
