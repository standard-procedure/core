module StandardProcedure
  module HasIcon
    extend ActiveSupport::Concern

    class_methods do
      def icon_name
        model_name.route_key
      end
    end

    def icon_name
      respond_to?(:icon) ? icon : model_name.singular_route_key
    end
  end
end
