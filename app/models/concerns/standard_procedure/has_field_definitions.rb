module StandardProcedure
  module HasFieldDefinitions
    extend ActiveSupport::Concern

    class_methods do
      def has_field_definitions
        has_many :field_definitions, -> { order :position }, class_name: "StandardProcedure::FieldDefinition", as: :definable, dependent: :destroy
      end

      def uses_field_definitions
        singleton_class.instance_eval do
          define_method :has_many do |name, scope = nil, **options, &extension|
            super name, scope, **options do
              def create_with_fields **params
                build.with_fields_from(source).tap do |model|
                  model.update(**params)
                end
              end

              def create_with_fields_from! source, **params
                build.with_fields_from(source).tap do |model|
                  model.update!(**params)
                end
              end

              def first_or_create_with_field_from source, **params
                first.present? ? first.with_fields_from(source) : create_with_fields_from(source, **params)
              end

              def first_or_create_with_fields_from! source, **params
                first.present? ? first.with_fields_from(source) : create_with_fields_from!(source, **params)
              end
              extension&.call
            end
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
