module StandardProcedure
  class Account < ApplicationRecord
    has_name
    has_logo
    has_many :contacts, class_name: "StandardProcedure::Contact", dependent: :destroy
    has_many :groups, class_name: "StandardProcedure::Group", dependent: :destroy
    has_and_belongs_to_many :managers, class_name: "StandardProcedure::Contact", join_table: "standard_procedure_managers", foreign_key: "account_id", association_foreign_key: "manager_id"
    has_many :folders, class_name: "StandardProcedure::Folder", dependent: :destroy
    has_many :workflows, class_name: "StandardProcedure::Workflow", dependent: :destroy
    include StandardProcedure::Account::Configuration

    validate :configuration_is_valid_yaml

    command :add_contact, :add_group, :add_manager, :add_folder, :add_workflow, :remove_contact, :remove_group, :remove_manager, :remove_folder, :remove_workflow

    protected

    def configuration_is_valid_yaml
      return if configuration.blank?
      YAML.load configuration
    rescue Psych::SyntaxError => se
      errors.add :configuration, se.message
    end
  end
end
