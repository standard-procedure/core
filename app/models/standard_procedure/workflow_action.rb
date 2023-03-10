module StandardProcedure
  class WorkflowAction < ApplicationRecord
    has_fields
    belongs_to :performed_by, class_name: "StandardProcedure::User"
    belongs_to :document, class_name: "StandardProcedure::Document"
    has_hash :configuration
    delegate :status, to: :document
    delegate :workflow, to: :status
    delegate :account, to: :workflow
    alias user performed_by

    def perform
    end

    # Do any initialisation before the action is performed and return self
    def prepare
      self
    end

    def contact
      account.contact_for user
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
          action.perform()
        end
      end

      def prepare_from(configuration)
        new(configuration: configuration).prepare
      end
    end

    protected

    def load_field_definitions
      Array
        .wrap(configuration[:fields])
        .each do |field_data|
          field_definitions.where(
            reference: field_data[:reference],
          ).first_or_initialize(field_data)
        end
    end
  end
end
