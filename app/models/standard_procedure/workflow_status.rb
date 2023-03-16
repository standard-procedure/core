module StandardProcedure
  class WorkflowStatus < ApplicationRecord
    has_name
    has_reference
    has_fields
    belongs_to :workflow, class_name: "StandardProcedure::Workflow"
    has_many :documents,
             class_name: "StandardProcedure::Document",
             dependent: :destroy
    acts_as_list scope: :workflow
    delegate :account, to: :workflow
    has_array :alerts
    has_array :assign_to
    has_array :actions

    command :document_added do |document:, performed_by:|
      user = performed_by
      document.alerts.each do |existing_alert|
        existing_alert.amend status: "inactive", performed_by: user
      end

      if default_contact_for(document).present?
        document.assign_to contact: default_contact_for(document),
                           performed_by: user
      end

      alerts.each do |alert_data|
        alert_data.symbolize_keys!
        # Only add this alert if it meets any "if" clauses in the definition
        next unless evaluate(alert_data, document)
        contacts =
          alert_data[:contacts]
            .map { |reference| document.find_contact_from(reference) }
            .compact
        hours = alert_data[:hours].hours
        document.add_alert type: alert_data[:type],
                           due_at: hours.from_now,
                           message: alert_data[:message],
                           contacts: contacts,
                           performed_by: user
      end
    end

    # `perform_action user, action_reference: @action_reference, document: document, **params`
    # - user: the user who is performing the action
    # - action_reference: the reference of the action to perform
    # - document: the document that will be acted on
    # - **params: any other parameters needed by the action
    command :perform_action do |action: nil, document: nil, performed_by:, **params|
      params =
        params.merge(configuration_for(action).excluding(:name, :reference))
      action_handler_for(action).perform(
        params.merge(document: document, performed_by: performed_by),
      )
    end

    command :add_alerts do |document: nil, performed_by:|
      alerts.each do |alert|
        document.add_alert due_at: nil, performed_by: performed_by
      end
    end

    def available_actions
      actions.map { |a| a["reference"] }
    end

    def name_for(action_reference)
      configuration_for(action_reference)[:name]
    end

    def required_fields_for(action_reference)
      build_action_for(action_reference).required_fields
    end

    def build_action(action_reference)
      action_handler_for(action_reference).prepare_from(
        configuration_for(action_reference),
      )
    end

    protected

    def default_contact_for(document)
      return nil if assign_to.blank?
      return @default_contact unless @default_contact.blank?

      # Go through the rules to see if any apply
      rule = assign_to.find { |rule| evaluate(rule.symbolize_keys, document) }
      @default_contact =
        rule.blank? ? nil : find_contact_from(rule.symbolize_keys)
      @default_contact
    end

    # If no "if" clause is supplied, we assume this is the default contact rule
    # If an "if" clause is supplied, we evaluate the "if" clause to see if it applies
    def evaluate(rule, document)
      rule[:if].blank? ? true : document.instance_eval(rule[:if])
    end

    def find_contact_from(rule)
      return account.contacts.find_by reference: rule[:contact]
    end

    def configuration_for(action_reference)
      action_reference = action_reference.to_s
      configuration =
        actions.find { |a| a["reference"] == action_reference } ||
          raise(InvalidActionReference.new("#{action_reference} not found"))
      return configuration.symbolize_keys
    end

    def action_handler_for(action_reference)
      configuration = configuration_for(action_reference)
      if configuration[:type].blank?
        StandardProcedure::WorkflowAction::UserDefined
      else
        configuration[:type].constantize
      end
    end
  end
end
