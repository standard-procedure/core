module StandardProcedure
  class WorkflowAction < ApplicationRecord
    has_fields
    has_field_definitions
    belongs_to :performed_by, polymorphic: true
    belongs_to :document, polymorphic: true
    has_hash :configuration
    has_field :primary, default: false
    has_field :colour, default: "neutral"
    delegate :status, to: :document
    delegate :workflow, to: :status
    delegate :account, to: :workflow
    alias_method :user, :performed_by

    def perform
    end

    # Do any initialisation before the action is performed and return self
    def prepare
      load_field_definitions
      self
    end

    # Resolve any internal fields described in the configuration
    def evaluate_contents contents
      return send(contents.to_sym) if respond_to? contents.to_sym
      return document.send(contents.to_sym) if document.respond_to? contents.to_sym
      contents
    end

    class << self
      # Create a new instance of this action,
      # then load the configuration, prepare any user-defined fields,
      # and perform the action
      # If this is a StandardProcedure::WorkflowAction::UserDefined then
      # params should include a :configuration key that lists the :fields and :outcomes
      def perform(params = {})
        configuration = params.delete(:configuration)
        prepare_from(configuration).tap do |action|
          action.update! params
          action.perform
        end
      end

      def prepare_from(configuration)
        new(configuration: configuration).prepare
      end
    end

    protected

    def load_field_definitions
      Array.wrap(configuration[:fields]).each do |field_data|
        field_definitions.where(reference: field_data[:reference]).first_or_initialize(field_data)
      end
      build_fields_from self
    end
  end
end
