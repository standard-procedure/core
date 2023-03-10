module StandardProcedure
  module HasCommands
    extend ActiveSupport::Concern

    class_methods do
      def defines_commands
        is_linked_to :commands,
                     class_name: "StandardProcedure::Command",
                     intermediary_class_name: "StandardProcedure::CommandLink"

        def command(*names, &implementation)
          Array
            .wrap(names)
            .each do |name|
              if implementation.nil?
                self.send(
                  :"define_#{command_type_for(name)}_command",
                  name,
                  &implementation
                )
              else
                define_standard_command(name, &implementation)
              end
            end
        end

        def define_standard_command(command_name, &implementation)
          command_name = command_name.to_sym
          unless available_commands.include? command_name
            available_commands << command_name
          end
          instance_eval do
            # Define the command wrapper (that checks authorisation and logs the outcome)
            define_method command_name do |**params|
              user = params.delete(:performed_by)
              authorise! command_name, user
              command =
                user.build_command_for self,
                                       command_name: command_name,
                                       **params
              user.acts_on self,
                           command: command,
                           command_name: command_name,
                           **params
            end
            # Define the asynchronous version if config.async is set
            define_method :"#{command_name}_later" do |**params|
              user = params.delete(:performed_by)
              authorise! command_name, user
              command =
                user.build_command_for self,
                                       command_name: command_name,
                                       **params
              ConcurrentRails::Promises.future do
                user.acts_on self,
                             command: command,
                             command_name: command_name,
                             **params
              end
            end if StandardProcedure.config.async
            define_method :"#{command_name}_implementation", &implementation
          end
        end

        def define_add_command(command_name, &implementation)
          association = association_from command_name, "add_"
          define_standard_command command_name.to_sym do |**params|
            user = params.delete(:performed_by)
            send(association).create! params
          end
        end

        def define_remove_command(command_name, &implementation)
          model_param = association_from command_name, "remove_", singular: true
          define_standard_command command_name.to_sym do |**params|
            user = params.delete(:performed_by)
            params[model_param]&.destroy
          end
        end

        define_method :authorised_to? do |do_command, user|
          user.respond_to?(:can?) ? user.can?(do_command, self) : false
        end

        define_method :authorise! do |do_command, user|
          unless authorised_to? do_command, user
            raise StandardProcedure::Command::Unauthorised
          end
        end

        define_method :available_commands do
          @available_commands ||= self.class.available_commands
        end

        define_method :available_commands_for do |user|
          available_commands
            .select { |command| authorised_to?(command, user) }
            .uniq
        end

        def available_commands
          @available_commands ||= []
        end

        def command_type_for(command_name)
          return :add if is_association_command?(command_name, "add_")
          return :remove if is_association_command?(command_name, "remove_")
          return :standard
        end

        def is_association_command?(command_name, prefix)
          command_name.to_s.starts_with?(prefix) &&
            reflect_on_association(
              association_from(command_name, prefix),
            ).present?
        end

        def association_from(command_name, prefix, singular: false)
          command_name = command_name.to_s.sub(prefix, "")
          singular ? command_name.to_sym : command_name.pluralize.to_sym
        end

        command :amend do |performed_by:, **params|
          user = params.delete(:performed_by)
          update! params
        end
      end

      def is_user
        has_many :performed_commands,
                 class_name: "StandardProcedure::Command",
                 as: :user,
                 dependent: :destroy

        define_method :call_stack do
          @call_stack ||= Concurrent::Array.new
        end

        define_method :current_context do
          call_stack.last
        end

        define_method :build_command_for do |target, command_name: nil, **params|
          command =
            performed_commands.create! target: target,
                                       context: current_context,
                                       command:
                                         "#{target.model_name.singular}_#{command_name}",
                                       status: "ready",
                                       params: params
        end

        define_method :acts_on do |target, command: nil, command_name: nil, **params, &implementation|
          raise ArgumentError "command not supplied" if command.blank?
          command.update status: "in_progress"
          call_stack << command
          begin
            user = self
            result =
              target.instance_eval do
                target.send :"#{command_name}_implementation",
                            **params.merge(performed_by: user)
              end
            command.update! status: "completed",
                            params: params.merge(result: result)
            return result
          rescue => ex
            command.update! status: "failed",
                            params: params.merge(error: ex.message)
            raise ex
          ensure
            call_stack.pop
          end
        end
      end
    end
  end
end
