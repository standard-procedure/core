module StandardProcedure
  module HasCommands
    extend ActiveSupport::Concern

    class_methods do
      def logs_actions
        is_linked_to :actions, class_name: "StandardProcedure::Action", intermediary_class_name: "StandardProcedure::ActionLink"

        def command(name, &block)
          is_add_command?(name) ? define_add_command(name) : define_standard_command(name, &block)
        end

        def authorise(command, &block)
          instance_eval { define_method :"authorise_#{command}?", &block }
        end

        def define_standard_command(name, &block)
          instance_eval { define_method name.to_sym, &block }
        end

        def define_add_command(name)
          command = name.to_sym
          association = association_from name
          instance_eval do
            define_method command do |user, **params|
              self.send(association).create! params
            end
          end
        end

        define_method :authorise! do |command, user, params|
          authorised = self.send :"authorise_#{command}?", user, **params
          raise StandardProcedure::Action::Unauthorised if !authorised
        end

        def is_add_command?(name)
          name.to_s.starts_with?("add_") && reflect_on_association(association_from(name)).present?
        end

        def association_from(name)
          name.to_s.sub("add_", "").pluralize.to_sym
        end
      end

      def is_user
        has_many :performed_actions, class_name: "StandardProcedure::Action", as: :user, dependent: :destroy

        define_method :tells do |target, to: nil, **params|
          command = to.to_sym
          target.authorise! command, self, params
          target.send(command, self, **params).tap do |result|
            action = performed_actions.create! target: target, command: "#{target.model_name.singular}_#{command}", status: "completed", params: params.merge(result: result)
          end
        end
      end
    end
  end
end
