module StandardProcedure
  module HasFieldDefinitions
    extend ActiveSupport::Concern

    class_methods do
      def has_field_definitions
        has_many :field_definitions, -> { order :position }, class_name: "Sp::Core::FieldDefinition", as: :definable, dependent: :destroy
      end
    end

    def custom_field_names
      fields.collect &:field_name
    end
  end
end
