module StandardProcedure
  module HasCommands
    extend ActiveSupport::Concern

    class_methods do
      def logs_actions
        is_linked_to :actions, class_name: "StandardProcedure::Action", intermediary_class_name: "StandardProcedure::ActionLink"

        def authorisations
          @authorisations ||= {}
        end

        def define_command(name, &block)
          instance_eval { define_method name.to_sym, &block }
        end

        def authorise(command, &block)
          instance_eval { define_method :"authorise_#{command}?", &block }
        end

        # For the Americans:
        alias :authorize :authorise

        define_method :authorise! do |command, params|
          authorised = self.send :"authorise_#{command}?", command, params
          raise StandardProcedure::Action::Unauthorised if !authorised
        end
      end

      def is_user
        has_many :performed_actions, class_name: "StandardProcedure::Action", as: :user, dependent: :destroy

        define_method :tells do |target, to: nil, **params|
          command = to.to_sym
          params.merge!(user: self)
          target.authorise! command, params
          target.send(command, **params).tap do |result|
            action = performed_actions.create! target: target, command: "#{target.model_name.singular}_#{command}", status: "completed", params: params.merge(result: result)
          end
        end
      end
    end
  end
end
