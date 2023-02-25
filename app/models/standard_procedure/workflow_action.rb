module StandardProcedure
  class WorkflowAction
    def initialize(configuration)
      super()
      @configuration = configuration
    end

    def required_fields
      @configuration["required_fields"] || self.class.required_fields
    end

    def act_on(item, user: nil, **params)
    end

    class << self
      def required_fields
        @required_fields ||= []
      end
    end

    protected

    attr_reader :configuration
  end
end
