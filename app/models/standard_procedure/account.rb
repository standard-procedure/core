module StandardProcedure
  class Account < ApplicationRecord
    has_name
    has_logo
    has_many :contacts, -> { order :name }, through: :groups
    has_many :folders, class_name: "StandardProcedure::Folder", dependent: :destroy
    has_many :workflows, class_name: "StandardProcedure::Workflow", dependent: :destroy
    include StandardProcedure::Account::Configuration
    include StandardProcedure::Account::Roles
    include StandardProcedure::Account::Groups

    command :add_group, :add_folder, :add_workflow, :remove_group, :remove_folder, :remove_workflow

    command :add_contact do |user, **params|
      group = params.delete :group
      group = groups.find_by!(reference: group) if group.is_a? String
      group.contacts.create! params
    end

    command :remove_contact do |user, **params|
      params[:contact].destroy
    end
  end
end
