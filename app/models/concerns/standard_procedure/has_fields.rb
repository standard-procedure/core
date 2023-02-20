module StandardProcedure
  module HasFields
    extend ActiveSupport::Concern

    class_methods do
      def has_fields(store_in: :field_data)
        storage = store_in.to_sym
        serialize storage, JSON
        define_method :field_storage do
          self.send(:"#{storage}=", {}) if self.send(storage).nil?
          self.send(storage)
        end
        has_array :models

        define_method :get_field do |name|
          self.field_storage[name.to_s]
        end

        define_method :set_field do |name, value|
          self.field_storage[name.to_s] = value
        end
      end

      def has_field(name)
        name = name.to_sym
        define_method name.to_sym do
          get_field name
        end
        define_method :"#{name}=" do |value|
          set_field name, value
        end
      end

      def has_model(name, class_name = nil)
        has_field :"#{name}_id"
        class_name ||= name.to_s.classify

        define_method name.to_sym do
          model_id = self.send :"#{name}_id"
          model_id.blank? ? nil : class_name.constantize.find_by(id: model_id)
        end
        define_method :"#{name}=" do |model|
          self.add_to_models model
          set_field "#{name}_id", model&.id
        end
      end

      def has_array(name)
        has_field :"#{name}_array"

        define_method name.to_sym do
          array = self.send :"#{name}_array"
          array.blank? ? [] : unwrap_array_field(array)
        end
        define_method :"#{name}=" do |array|
          self.send :"#{name}_array=", wrap_array_field(array)
        end
        define_method :"add_to_#{name}" do |items|
          self.send :"#{name}=", (self.send(name.to_sym) + Array.wrap(item))
        end
      end

      def has_hash(name)
        has_field :"#{name}_hash"

        define_method name.to_sym do
          hash = self.send :"#{name}_hash"
          hash.blank? ? {} : unwrap_hash_field(hash)
        end
        define_method :"#{name}=" do |hash|
          self.send :"#{name}_hash=", wrap_hash_field(hash)
        end
      end
    end

    def unwrap_array_field(array)
      array.map do |value|
        # is this a global ID (which is stored as { "uri" => "some_id"})?
        (value.respond_to?(:has_key?) && value.has_key?("uri")) ? GlobalID::Locator.locate(value["uri"]) : value
      end
    end

    def wrap_array_field(array)
      return [] if array.blank?
      array.map do |value|
        value.respond_to?(:to_global_id) ? value.to_global_id : value
      end
    end

    def unwrap_hash_field(hash)
      hash.transform_values do |value|
        # is this a global ID?
        (value.respond_to?(:starts_with?) && value.starts_with?("gid:")) ? GlobalID::Locator.locate(value) : value rescue nil
      end
    end

    def wrap_hash_field(hash)
      hash.transform_values do |value|
        value.respond_to?(:to_global_id) ? value.to_global_id.to_s : value
      end
    end
  end
end
