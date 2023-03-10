module StandardProcedure
  class Account
    module Templates
      extend ActiveSupport::Concern

      included do
        has_many :templates,
                 -> { order :name },
                 class_name: "StandardProcedure::DocumentTemplate",
                 dependent: :destroy
        has_many :items, -> { order :position }, through: :templates

        command :add_template, :remove_template
      end

      protected

      def build_templates_from_configuration
        build_configuration_for :templates,
                                include_fields: true,
                                params: %i[reference name plural type item_type]
      end
    end
  end
end
