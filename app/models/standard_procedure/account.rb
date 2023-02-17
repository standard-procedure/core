module StandardProcedure
  class Account < ApplicationRecord
    has_name
    has_logo
    has_many :contacts, -> { order :name }, through: :groups
    has_many :groups, class_name: "StandardProcedure::Group", dependent: :destroy
    has_many :folders, class_name: "StandardProcedure::Folder", dependent: :destroy
    has_many :workflows, class_name: "StandardProcedure::Workflow", dependent: :destroy
    include StandardProcedure::Account::Configuration
    include StandardProcedure::Account::Roles

    validate :configuration_is_valid_yaml

    command :add_group, :add_manager, :add_folder, :add_workflow, :remove_group, :remove_manager, :remove_folder, :remove_workflow

    command :add_contact do |user, **params|
      group = params.delete :group
      group = groups.find_by!(reference: group) if group.is_a? String
      group.contacts.create! params
    end

    command :remove_contact do |user, **params|
      params[:contact].destroy
    end

    protected

    def configuration_is_valid_yaml
      return if configuration.blank?
      YAML.load configuration
    rescue Psych::SyntaxError => se
      errors.add :configuration, se.message
    end
  end
end
