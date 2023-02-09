module StandardProcedure
  module HasCommands
    extend ActiveSupport::Concern

    class_methods do
      def defines_commands
        is_linked_to :actions, class_name: "StandardProcedure::Action", intermediary_class_name: "StandardProcedure::ActionLink"

        def command(*names, &implementation)
          Array.wrap(names).each do |name|
            implementation.nil? ? self.send(:"define_#{command_type_for(name)}_command", name, &implementation) : define_standard_command(name, &implementation)
          end
        end

        def define_standard_command(name, &implementation)
          command = name.to_sym
          available_commands << command unless available_commands.include? command
          instance_eval do
            # Define the command wrapper (that checks authorisation and logs the outcome)
            define_method command do |user, **params|
              authorise! command, user
              action = user.build_action_for self, command: command, **params
              user.acts_on self, action: action, command: command, **params
            end
            # Define the asynchronous version if config.async is set
            define_method :"#{command}_later" do |user, **params|
              authorise! command, user
              action = user.build_action_for self, command: command, **params
              ConcurrentRails::Promises.future do
                user.acts_on self, action: action, command: command, **params
              end
            end if StandardProcedure.config.async
            define_method :"#{command}_implementation", &implementation
          end
        end

        def define_add_command(name, &implementation)
          association = association_from name, "add_"
          define_standard_command name.to_sym do |user, **params|
            send(association).create! params
          end
        end

        def define_remove_command(name, &implementation)
          model_param = association_from name, "remove_", singular: true
          define_standard_command name.to_sym do |user, **params|
            params[model_param]&.destroy
          end
        end

        define_method :authorised_to? do |do_command, user|
          user.respond_to?(:can?) ? user.can?(do_command, self) : false
        end

        define_method :authorise! do |do_command, user|
          raise StandardProcedure::Action::Unauthorised unless authorised_to? do_command, user
        end

        define_method :available_commands do
          @available_commands ||= self.class.available_commands
        end

        define_method :available_commands_for do |user|
          available_commands.select { |command| authorised_to?(command, user) }.uniq
        end

        def available_commands
          @available_commands ||= []
        end

        def command_type_for(name)
          return :add if is_association_command?(name, "add_")
          return :remove if is_association_command?(name, "remove_")
          return :standard
        end

        def is_association_command?(name, prefix)
          name.to_s.starts_with?(prefix) && reflect_on_association(association_from(name, prefix)).present?
        end

        def association_from(name, prefix, singular: false)
          name = name.to_s.sub(prefix, "")
          singular ? name.to_sym : name.pluralize.to_sym
        end

        command :amend do |user, **params|
          update! params
        end
      end

      def is_user
        has_many :performed_actions, class_name: "StandardProcedure::Action", as: :user, dependent: :destroy

        define_method :call_stack do
          @call_stack ||= Concurrent::Array.new
        end

        define_method :current_context do
          call_stack.last
        end

        define_method :build_action_for do |target, command: nil, **params|
          action = performed_actions.create! target: target, context: current_context, command: "#{target.model_name.singular}_#{command}", status: "ready", params: params
        end

        define_method :acts_on do |target, action: nil, command: nil, **params, &implementation|
          raise ArgumentError "action not supplied" if action.blank?
          action.update status: "in_progress"
          call_stack << action
          begin
            user = self
            result = target.instance_eval do
              target.send :"#{command}_implementation", user, **params
            end
            action.update! status: "completed", params: params.merge(result: result)
            return result
          rescue => ex
            action.update! status: "failed", params: params.merge(error: ex.message)
            raise ex
          ensure
            call_stack.pop
          end
        end
      end
    end
  end
end
