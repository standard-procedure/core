module StandardProcedure
  class Account
    module Configuration
      extend ActiveSupport::Concern
      included { validate :configuration_is_valid_yaml }

      def config_for(section)
        Array.wrap(config[section.to_sym])
      end

      def configure_from(config_file)
        update! configuration: config_file
        build_roles_from_configuration
        build_organisations_from_configuration
        build_workflows_from_configuration
        build_templates_from_configuration
        return self
      end

      protected

      def config
        @config ||=
          (
            if configuration.blank?
              {}
            else
              YAML.load(configuration).deep_symbolize_keys
            end
          )
      end

      def configuration_is_valid_yaml
        return if configuration.blank?
        YAML.load configuration
      rescue Psych::SyntaxError => se
        errors.add :configuration, se.message
      end

      def build_configuration_for(
        things,
        target: self,
        configuration: nil,
        include_fields: false,
        params: %i[reference name plural type]
      )
        configuration ||= config_for(things)
        collection = target.send things

        configuration.each do |data|
          next if collection.find_by(reference: data[:reference]).present?
          thing = collection.create! data.slice(*params)
          if include_fields
            Array
              .wrap(data[:fields])
              .each do |field_data|
                thing
                  .field_definitions
                  .where(reference: field_data[:reference])
                  .first_or_create!(field_data)
              end
          end
          yield thing, data if block_given?
        end
      end
    end
  end
end
