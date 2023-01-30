module StandardProcedure
  module HasFieldValues
    extend ActiveSupport::Concern

    class_methods do
      def has_field_values(store_in: :field_data)
        has_fields(store_in: store_in)

        define_method :with_fields_from do |field_definitions, &block|
          field_definitions.each do |field_definition|
            define_singleton_method field_definition.reader do
              field_definition.read_from self
            end
            define_singleton_method field.writer do |value|
              field_definition.write_to self, value
            end
          end
          block&.call(self)
          return self
        end
      end
    end
  end
end
