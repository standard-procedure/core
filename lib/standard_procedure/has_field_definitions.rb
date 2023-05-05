module StandardProcedure
  module HasFieldDefinitions
    extend ActiveSupport::Concern

    class_methods do
      def has_field_definitions
        has_many :field_definitions, -> { order :position }, class_name: "StandardProcedure::FieldDefinition", as: :definable, dependent: :destroy
      end

      def has_many_extended name, scope = nil, **options, &extension
        has_many name, scope, **options do
          instance_eval do
            define_method :create_with_fields do |**params|
              build.with_fields_from(source).tap do |model|
                model.update(**params)
              end
            end

            define_method :create_with_fields_from! do |source, **params|
              build.with_fields_from(source).tap do |model|
                model.update!(**params)
              end
            end

            define_method :first_or_create_with_field_from do |source, **params|
              first.present? ? first.with_fields_from(source) : create_with_fields_from(source, **params)
            end

            define_method :first_or_create_with_fields_from! do |source, **params|
              first.present? ? first.with_fields_from(source) : create_with_fields_from!(source, **params)
            end
            extension&.call
          end
        end
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
