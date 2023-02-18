module StandardProcedure
  class Account
    module Groups
      extend ActiveSupport::Concern

      included do
        has_many :groups, class_name: "StandardProcedure::Group", dependent: :destroy
        has_many :contacts, -> { order :name }, through: :groups
      end

      protected

      def build_groups_from_configuration
        config_for(:groups).each do |group_data|
          next if groups.find_by(reference: group_data[:reference]).present?
          group = groups.create group_data.slice(:reference, :name, :plural, :type)
          Array.wrap(group_data[:fields]).each do |field_data|
            group.fields.where(reference: field_data[:reference]).first_or_create!(field_data)
          end
        end
      end
    end
  end
end
