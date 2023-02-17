module StandardProcedure
  class Account
    module Configuration
      extend ActiveSupport::Concern

      def config_for(section)
        Array.wrap(config[section.to_sym])
      end

      def configure_from(config_file)
        update! configuration: config_file
        build_groups_from_configuration
      end

      protected

      def config
        @config ||= configuration.blank? ? {} : YAML.load(configuration).deep_symbolize_keys
      end

      def build_groups_from_configuration
        config_for(:groups).each do |group_data|
          next if groups.find_by(reference: group_data[:reference]).present?
          puts group_data
          groups.create group_data
        end
      end
    end
  end
end
