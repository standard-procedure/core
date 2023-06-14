module StandardProcedure
  module HasFields
    extend ActiveSupport::Concern

    class_methods do
      def has_fields(store_in: :field_data)
        storage = store_in.to_sym
        serialize storage, JSON
        define_method :_field_storage do
          send(:"#{storage}=", {}) if send(storage).nil?
          send(storage)
        end
        define_method :_model_cache do
          @_model_cache ||= {}
        end

        has_array :models

        define_method :get_field do |name|
          _field_storage[name.to_s]
        end

        define_method :set_field do |name, value|
          _field_storage[name.to_s] = value
        end

        define_method :build_fields_from do |source|
          Array.wrap(source&.field_definitions).each do |field_definition|
            field_definition.define_on self
          end
          singleton_class.instance_eval do
            define_method :field_names do
              Array.wrap(source&.field_names)
            end
            define_method :field_accessors do
              Array.wrap(source&.field_accessors)
            end
          end
        end

        define_method :with_fields_from do |source, &block|
          build_fields_from source
          block&.call self
          self
        end
      end

      def has_field(name, default: nil, boolean: false)
        name = name.to_sym
        define_method name.to_sym do
          value = get_field(name) || default
          boolean ? ActiveRecord::Type::Boolean.new.cast(value) : value
        end
        define_method :"#{name}=" do |value|
          set_field name, value
        end
        if boolean
          define_method :"#{name}?" do
            send name.to_sym
          end
        end
      end

      def has_model(name, class_name)
        has_field :"#{name}_id"
        class_name ||= name.to_s.classify

        define_method name.to_sym do
          _model_cache[name.to_sym] ||= send(:"_#{name}")
        end

        define_method :"_#{name}" do
          model_id = send :"#{name}_id"
          model_id.blank? ? nil : class_name.constantize.find_by(id: model_id)
        end

        define_method :"#{name}=" do |model|
          _model_cache[name.to_sym] = model
          _add_to_models model
          set_field "#{name}_id", model&.id
        end
      end

      def has_array(name)
        has_field :"#{name}_array"

        define_method name.to_sym do
          array = send :"#{name}_array"
          array.blank? ? [] : _unwrap_array_field(array)
        end
        define_method :"#{name}=" do |array|
          send :"#{name}_array=", _wrap_array_field(array)
        end
        define_method :"add_to_#{name}" do |items|
          send :"#{name}=", (send(name.to_sym) + Array.wrap(item))
        end
      end

      def has_hash(name)
        has_field :"#{name}_hash"

        define_method name.to_sym do
          hash = send :"#{name}_hash"
          hash.blank? ? {} : _unwrap_hash_field(hash)
        end
        define_method :"#{name}=" do |hash|
          send :"#{name}_hash=", _wrap_hash_field(hash)
        end
      end

      def create_with_fields_from source, **params
        new.with_fields_from(source).tap do |model|
          model.update(**params)
        end
      end

      def create_with_fields_from! source, **params
        new.with_fields_from(source).tap do |model|
          model.update!(**params)
        end
      end
    end

    def has_field(name, default: nil, boolean: false)
      singleton_class.has_field name, default: default, boolean: boolean
    end

    def has_model(name, class_name)
      singleton_class.has_model name, class_name
    end

    def has_array(name)
      singleton_class.has_array name
    end

    def has_hash(name)
      singleton_class.has_hash name
    end

    protected

    def _unwrap_array_field(array)
      return [] if array.blank?
      array.map do |value|
        # is this a global ID (which is stored as { "uri" => "some_id"})?
        (value.respond_to?(:starts_with?) && value.starts_with?("gid")) ? GlobalID::Locator.locate(value) : value
      rescue
        nil
      end
    end

    def _wrap_array_field(array)
      return [] if array.blank?
      array.map do |value|
        value.respond_to?(:to_global_id) ? value.to_global_id : value
      rescue
        nil
      end
    end

    def _unwrap_hash_field(hash)
      return {} if hash.blank?
      hash.transform_values do |value|
        # is this a global ID?

        (value.respond_to?(:starts_with?) && value.starts_with?("gid:")) ? GlobalID::Locator.locate(value) : value
      rescue
        nil
      end.deep_symbolize_keys
    end

    def _wrap_hash_field(hash)
      return {} if hash.blank?
      hash.transform_values do |value|
        value.respond_to?(:to_global_id) ? value.to_global_id.to_s : value
      rescue
        nil
      end
    end

    def _add_to_models(model)
      models << model
    end
  end
end
