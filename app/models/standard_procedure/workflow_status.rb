module StandardProcedure
  class WorkflowStatus < ApplicationRecord
    has_name
    has_reference
    has_fields
    belongs_to :workflow, class_name: "StandardProcedure::Workflow"
    has_many :items, class_name: "StandardProcedure::WorkflowItem", dependent: :destroy
    acts_as_list scope: :workflow
    delegate :account, to: :workflow
    has_array :alerts

    command :item_added do |user, **params|
      item = params[:item]

      alerts.each do |alert_data|
        alert_data.symbolize_keys!
        contacts = alert_data[:contacts].collect do |reference|
          account.contacts.find_by(reference: reference)
        end
        hours = alert_data[:hours].hours
        item.add_alert user, type: alert_data[:type], due_at: hours.from_now, contacts: contacts
      end
    end
  end
end
