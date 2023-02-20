module StandardProcedure
  class Account < ApplicationRecord
    has_name
    has_logo
    has_many :folders, class_name: "StandardProcedure::Folder", dependent: :destroy
    has_many :workflows, class_name: "StandardProcedure::Workflow", dependent: :destroy
    include StandardProcedure::Account::Configuration
    include StandardProcedure::Account::Roles
    include StandardProcedure::Account::Groups
    include StandardProcedure::Account::Workflows
    include StandardProcedure::Account::Templates

    command :add_group, :add_folder, :add_workflow, :add_template, :remove_group, :remove_folder, :remove_workflow, :remove_template

    command :add_contact do |user, **params|
      group = params.delete(:group)
      group = groups.find_by!(reference: group) if group.is_a? String
      params[:role] = roles.find_by!(reference: params[:role]) if params[:role].is_a? String
      params[:reference] ||= params[:name]
      group.contacts.create! params
    end

    command :remove_contact do |user, **params|
      params[:contact].destroy
    end
  end
end
