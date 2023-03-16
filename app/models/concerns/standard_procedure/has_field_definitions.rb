module StandardProcedure
  module HasFieldDefinitions
    extend ActiveSupport::Concern

    class_methods do
      def has_field_definitions
        has_many :field_definitions, -> { order :position }, class_name: "StandardProcedure::FieldDefinition", as: :definable, dependent: :destroy
      end
    end

    def field_names
      field_definitions.collect(&:field_name)
    end

    def field_accessors
      field_definitions.collect(&:reader)
    end
  end
end
