module StandardProcedure
  class ApplicationJob < ActiveJob::Base
    retry_on ActiveRecord::Deadlocked
    discard_on ActiveJob::DeserializationError
    attr_accessor :context_id
    around_perform do |job, block|
      context = job.context_id.blank? ? StandardProcedure::Command.context : StandardProcedure::Command.find(job.context_id)
      target = job.arguments.first.is_a?(ActiveRecord::Base) ? job.arguments.first : nil
      params = job.arguments.last.is_a?(Hash) ? job.arguments.last : {}
      user = params[:user]
      StandardProcedure::Command.create!(context: context, user: user, target: target, command: self.class.name, job_id: job.job_id, params: params, status: "in_progress").tap do |command|
        StandardProcedure::Command.context_stack << command
        begin
          params.values.each do |value|
            command.link_to(value) if value.respond_to? :commands
          end
          result = block.call
          command.update status: "completed", params: command.params.merge(result: result)
        rescue => ex
          command.update status: "failed", params: command.params.merge(error: ex.inspect)
          raise ex
        ensure
          StandardProcedure::Command.context_stack.pop
        end
      end
    end

    def serialize
      super.merge("context_id" => StandardProcedure::Command.context&.id)
    end

    def deserialize(data)
      super
      self.context_id = data["context_id"]
    end
  end
end
