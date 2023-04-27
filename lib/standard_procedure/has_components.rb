module StandardProcedure
  module HasComponents
    extend ActiveSupport::Concern

    class_methods do
      def component_name aspect = nil, prefix: nil
        [prefix, model_name.collection.singularize, aspect].compact.join("/")
      end
    end

    def component_name aspect = nil, prefix: nil
      self.class.component_name aspect, prefix: prefix
    end
  end
end
