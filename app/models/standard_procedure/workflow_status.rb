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
    has_array :assign_to
    has_array :actions

    command :item_added do |user, item: nil|
      item.alerts.each do |existing_alert|
        existing_alert.amend user, status: "inactive"
      end

      item.assign_to user, contact: default_contact_for(item) unless default_contact_for(item).blank?

      alerts.each do |alert_data|
        alert_data.symbolize_keys!
        # Only add this alert if it meets any "if" clauses in the definition
        next unless evaluate(alert_data, item)
        contacts = alert_data[:contacts].map { |reference| item.find_contact_from(reference) }
        hours = alert_data[:hours].hours
        item.add_alert user, type: alert_data[:type], due_at: hours.from_now, message: alert_data[:message], contacts: contacts
      end
    end

    # `perform_action user, action_reference: @action_reference, item: @workflow_item, **params`
    # - user: the user who is performing the action
    # - action_reference: the reference of the action to perform
    # - item: the workflow-item that will be acted on
    # - **params: any other parameters needed by the action
    command :perform_action do |user, action_reference: nil, item: nil, **params|
      params = params.merge(configuration_for(action_reference).excluding(:name, :reference))
      action_handler_for(action_reference).perform(params.merge(user: user, item: item))
    end

    command :add_alerts do |user, item: nil|
      alerts.each do |alert|
        item.add_alert user, due_at:
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
      action_handler_for(action_reference).prepare_from(configuration_for(action_reference))
    end

    protected

    def default_contact_for(item)
      return nil if assign_to.blank?
      return @default_contact unless @default_contact.blank?

      # Go through the rules to see if any apply
      rule = assign_to.find { |rule| evaluate(rule.symbolize_keys, item) }
      @default_contact = rule.blank? ? nil : find_contact_from(rule.symbolize_keys)
    end

    # If no "if" clause is supplied, we assume this is the default contact rule
    # If an "if" clause is supplied, we evaluate the "if" clause to see if it applies
    def evaluate(rule, item)
      rule[:if].blank? ? true : item.instance_eval(rule[:if])
    end

    def find_contact_from(rule)
      return account.contacts.find_by reference: rule[:contact]
    end

    def configuration_for(action_reference)
      action_reference = action_reference.to_s
      configuration = actions.find { |a| a["reference"] == action_reference } || raise(InvalidActionReference.new("#{action_reference} not found"))
      return configuration.symbolize_keys
    end

    def action_handler_for(action_reference)
      configuration = configuration_for(action_reference)
      configuration[:type].blank? ? StandardProcedure::WorkflowAction::UserDefined : configuration[:type].constantize
    end
  end
end
