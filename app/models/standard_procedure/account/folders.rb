module StandardProcedure
  class Account
    module Folders
      extend ActiveSupport::Concern

      included do
        has_many :folders, -> { order :name }, class_name: "StandardProcedure::Folder", foreign_key: "account_id", dependent: :destroy
        has_many :organisations, -> { order :name }, class_name: "StandardProcedure::Organisation", foreign_key: "account_id"
        has_many :contacts, -> { order :name }, class_name: "StandardProcedure::Contact", foreign_key: "account_id"
      end

      protected

      def build_organisations_from_configuration
        build_configuration_for :organisations, include_fields: true
      end
    end
  end
end
