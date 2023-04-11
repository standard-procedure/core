module StandardProcedure
  module HasComponent
    extend ActiveSupport::Concern

    def component_name
      model_name.collection
    end
  end
end
