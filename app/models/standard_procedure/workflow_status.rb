module StandardProcedure
  class WorkflowStatus < ApplicationRecord
    has_name
    has_reference scope: :workflow
    has_fields
    reference_to :workflow, class_name: "StandardProcedure::Workflow"
    acts_as_list scope: :workflow
    delegate :account, to: :workflow
    has_array :alerts
    has_array :assign_to
    has_array :actions

    command :document_added do |document:, performed_by:|
      user = performed_by
      document.alerts.each { |existing_alert| existing_alert.amend status: "inactive", performed_by: user }

      document.assign_to contact: default_contact_for(document), performed_by: user if default_contact_for(document).present?

      alerts.each do |alert_data|
        alert_data.symbolize_keys!
        #  Only add this alert if it meets any "if" clauses in the definition
        next unless evaluate(alert_data, document)
        contacts = alert_data[:contacts].map { |reference| document.find_contact_from(reference) }.compact
        hours = alert_data[:hours].hours
        document.add_alert type: alert_data[:type], due_at: hours.from_now, message: alert_data[:message], contacts: contacts, performed_by: user
      end
    end

    # `perform_action action: "action", document: @document, performed_by: @user, **params`
    command :perform_action do |action: nil, document: nil, performed_by: nil, **params|
      params = params.merge(configuration_for(action).excluding(:name, :reference))
      action_handler_for(action).perform(params.merge(document: document, performed_by: performed_by))
    end

    command :add_alerts do |performed_by:, document: nil|
      alerts.each do |alert|
        document.add_alert due_at: nil, performed_by: performed_by
      end
    end

    def available_actions
      actions.map { |a| a["reference"] }
    end

    def primary_action_reference
      primary_action.blank? ? nil : primary_action["reference"]
    end

    def primary_action_colour
      primary_action.blank? ? nil : primary_action["colour"]
    end

    def name_for(action_reference)
      configuration_for(action_reference)[:name]
    end

    def required_fields_for(action_reference)
      build_action_for(action_reference).required_fields
    end

    def build_action(action_reference)
      action_handler_for(action_reference).prepare_from(configuration_for(action_reference))
    end

    protected

    def default_contact_for(document)
      return nil if assign_to.blank?
      return @default_contact unless @default_contact.blank?
      # Go through the rules to see if any apply
      rule = assign_to.find { |rule| evaluate(rule.symbolize_keys, document) }
      @default_contact = rule.blank? ? nil : find_contact_from(rule.symbolize_keys)
    end

    # If no "if" clause is supplied, we assume this is the default contact rule
    # If an "if" clause is supplied, we evaluate the "if" clause to see if it applies
    def evaluate(rule, document)
      rule[:if].blank? ? true : document.instance_eval(rule[:if])
    end

    def find_contact_from(rule)
      account.contacts.find_by reference: rule[:contact]
    end

    def primary_action
      @primary_action ||= actions.find { |a| a["primary"] }
    end

    def configuration_for(action_reference)
      action_reference = action_reference.to_s
      configuration = actions.find { |a| a["reference"] == action_reference } || raise(InvalidActionReference.new("#{action_reference} not found"))
      configuration.symbolize_keys
    end

    def action_handler_for(action_reference)
      configuration = configuration_for(action_reference)
      configuration[:type].blank? ? StandardProcedure::WorkflowAction::UserDefined : configuration[:type].constantize
    end
  end
end
