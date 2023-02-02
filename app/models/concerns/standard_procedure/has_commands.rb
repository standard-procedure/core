module StandardProcedure
  module HasCommands
    extend ActiveSupport::Concern

    class_methods do
      def logs_actions
        is_linked_to :actions, class_name: "StandardProcedure::Action", intermediary_class_name: "StandardProcedure::ActionLink"

        def command(name, &implementation)
          return define_add_command(name) if is_add_command?(name)
          return define_delete_command(name) if is_delete_command?(name)
          define_standard_command(name, &implementation)
        end

        def authorise(command, &permission_check)
          instance_eval { define_method :"authorise_#{command}?", &permission_check }
        end

        def define_standard_command(name, &implementation)
          command = name.to_sym
          available_commands << command
          instance_eval do
            define_method command do |user, **params|
              authorise! command, user
              user.acts_on self, command: command, **params
            end
            define_method :"#{command}_implementation", &implementation
          end
        end

        def define_add_command(name)
          association = association_from name, "add_"
          define_standard_command name.to_sym do |user, **params|
            send(association).create! params
          end
        end

        def define_delete_command(name)
          association = association_from name, "delete_"
          model_param = association_from name, "delete_", singular: true
          define_standard_command name.to_sym do |user, **params|
            params[model_param]&.destroy
          end
        end

        define_method :authorised_to? do |command, user|
          authorisation = :"authorise_#{command}?"
          self.respond_to?(authorisation) && self.send(authorisation, user)
        end

        define_method :authorise! do |command, user|
          raise StandardProcedure::Action::Unauthorised unless authorised_to?(command, user)
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

        def is_add_command?(name)
          is_association_command?(name, "add_")
        end

        def is_delete_command?(name)
          is_association_command?(name, "delete_")
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

        define_method :acts_on do |target, command: nil, **params, &implementation|
          action = performed_actions.create! target: target, context: current_context, command: "#{target.model_name.singular}_#{command}", status: "in_progress", params: params
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
