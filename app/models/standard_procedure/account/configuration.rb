module StandardProcedure
  class Account
    module Configuration
      extend ActiveSupport::Concern

      def config
        @config ||= YAML.load(configuration).deep_symbolize_keys
      end

      def configure(config_file)
        update! configuration: config_file
        build_groups_from_configuration
      end

      protected

      def build_groups_from_configuration
        puts config[:groups]
        config[:groups].each do |group_data|
          next if groups.find_by(reference: group_data[:reference]).present?
          groups.create group_data
        end
      end
    end
  end
end
