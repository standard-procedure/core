module StandardProcedure
  module HasFieldValues
    extend ActiveSupport::Concern

    class_methods do
      def has_field_values(store_in: :field_data)
        self.has_fields(store_in: store_in)

        define_method :with_fields_from do |field_definitions, &block|
          field_definitions.each do |field_definition|
            field_definition.define_on self
          end
          block&.call(self)
          return self
        rescue => ex
          puts ex.inspect
        end
      end
    end
  end
end
