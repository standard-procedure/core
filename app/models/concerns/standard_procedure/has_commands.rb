module StandardProcedure
  module HasCommands
    extend ActiveSupport::Concern

    class_methods do
      def logs_actions
        is_linked_to :actions, class_name: "StandardProcedure::Action", intermediary_class_name: "StandardProcedure::ActionLink"
        after_initialize do |target|
          target.class.command_implementations.each do |command, implementation|
            target.define_singleton_method command, &implementation
          end
        end

        def command_implementations
          @command_implementations ||= {}
        end

        def available_commands
          command_implementations.keys
        end

        def define_command(name, &block)
          command_implementations[name.to_sym] = block
        end

        define_method :available_commands do
          self.class.available_commands
        end
      end

      def is_user
        has_many :performed_actions, class_name: "StandardProcedure::Action", as: :user, dependent: :destroy

        define_method :tells do |target, to: nil, **params|
          command = to.to_sym
          target.send(command, **params).tap do |result|
            action = performed_actions.create! target: target, command: action_command_for(target, command), params: params.merge(result: result)
          end
        end

        define_method :action_command_for do |target, command|
          "#{target.model_name.singular}_#{command}"
        end
      end
    end
  end
end
