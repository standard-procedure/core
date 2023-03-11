module StandardProcedure
  class WorkflowStatus < ApplicationRecord
    has_name
    has_reference
    has_fields
    belongs_to :workflow, class_name: "StandardProcedure::Workflow"
    has_many :items,
             class_name: "StandardProcedure::WorkflowItem",
             dependent: :destroy
    acts_as_list scope: :workflow
    delegate :account, to: :workflow
    has_array :alerts
    has_array :assign_to
    has_array :actions

    command :item_added do |item:, performed_by:|
      user = performed_by
      item.alerts.each do |existing_alert|
        existing_alert.amend status: "inactive", performed_by: user
      end

      unless default_contact_for(item).blank?
        item.assign_to contact: default_contact_for(item), performed_by: user
      end

      alerts.each do |alert_data|
        alert_data.symbolize_keys!
        # Only add this alert if it meets any "if" clauses in the definition
        next unless evaluate(alert_data, item)
        contacts =
          alert_data[:contacts].map do |reference|
            item.find_contact_from(reference)
          end
        hours = alert_data[:hours].hours
        item.add_alert type: alert_data[:type],
                       due_at: hours.from_now,
                       message: alert_data[:message],
                       contacts: contacts,
                       performed_by: user
      end
    end

    # `perform_action user, action_reference: @action_reference, item: @workflow_item, **params`
    # - user: the user who is performing the action
    # - action_reference: the reference of the action to perform
    # - item: the workflow-item that will be acted on
    # - **params: any other parameters needed by the action
    command :perform_action do |action_reference: nil, item: nil, **params|
      params =
        params.merge(
          configuration_for(action_reference).excluding(:name, :reference),
        )
      action_handler_for(action_reference).perform(params.merge(item: item))
    end

    command :add_alerts do |item: nil, performed_by:|
      alerts.each do |alert|
        item.add_alert due_at: nil, performed_by: performed_by
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

    def default_contact_for(item)
      return nil if assign_to.blank?
      return @default_contact unless @default_contact.blank?

      # Go through the rules to see if any apply
      rule = assign_to.find { |rule| evaluate(rule.symbolize_keys, item) }
      @default_contact =
        rule.blank? ? nil : find_contact_from(rule.symbolize_keys)
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
