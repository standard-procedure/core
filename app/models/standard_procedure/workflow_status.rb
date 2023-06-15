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

    def document_added document:, performed_by:, action: nil
      WorkflowStatus::DocumentAddedJob.perform_now self, document: document, user: performed_by, action: action
    end

    # `perform_action action: "action", document: @document, performed_by: @user, **params`
    def perform_action action: nil, document: nil, performed_by: nil, **params
      WorkflowStatus::PerformActionJob.perform_now self, action: action, document: document, user: performed_by, **params
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
      action_handler_for(action_reference).prepare_from(configuration_for(action_reference)[:configuration])
    end

    def default_contact_for(document)
      return nil if assign_to.blank?
      return @default_contact unless @default_contact.blank?
      # Go through the rules to see if any apply
      rule = assign_to.find { |rule| evaluate(rule.symbolize_keys, document) }
      @default_contact = rule.blank? ? nil : document._workflow_find_user(rule.symbolize_keys[:contact])
    end

    # If no "if" clause is supplied, we assume this is the default contact rule
    # If an "if" clause is supplied, we evaluate the "if" clause to see if it applies
    def evaluate(rule, document)
      rule[:if].blank? ? true : document.instance_eval(rule[:if])
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
