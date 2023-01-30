module Sp
  module Core
    module AddFieldDefinition
      extend ActiveSupport::Concern

      included do
        has_field :name
        has_field :field_type
        has_field :position
        has_field :mandatory
        has_field :options
        has_field :default
        has_field :organisation
      end

      def perform
        klass = field_type.constantize
        mandatory = false if mandatory.blank?
        klass.where(customisable: target, name: name).first_or_create!(mandatory: mandatory, options: options).tap do |fd|
          fd.insert_at(position)
        end
      end
    end
  end
end
