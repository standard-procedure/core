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

        def authorisations
          @authorisations ||= {}
        end

        def available_commands
          command_implementations.keys
        end

        def define_command(name, &block)
          command_implementations[name.to_sym] = block
        end

        def authorise(command, &block)
          authorisations[command.to_sym] = block
        end

        # For the Americans:
        alias :authorize :authorise

        def authorised?(command, params)
          user = params[:user]
          authorisations[command]&.call(user, params)
        end

        define_method :available_commands do
          self.class.available_commands
        end

        define_method :authorisations do
          self.class.authorisations
        end

        define_method :authorise! do |command, params|
          raise StandardProcedure::Action::Unauthorised unless self.class.authorised? command, params
        end
      end

      def is_user
        has_many :performed_actions, class_name: "StandardProcedure::Action", as: :user, dependent: :destroy

        define_method :tells do |target, to: nil, **params|
          command = to.to_sym
          params.merge!(user: self)
          target.authorise! command, params
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
