module StandardProcedure
  class Account < ApplicationRecord
    has_name
    has_logo
    has_many :contacts, class_name: "StandardProcedure::Contact", dependent: :destroy
    has_many :groups, class_name: "StandardProcedure::Group", dependent: :destroy
    has_many_and_belongs_to_many :managers, class_name: "StandardProcedure::Contact", join_table: "standard_procedure_managers"
    has_many :folders, class_name: "StandardProcedure::Folder", dependent: :destroy
    has_many :workflows, class_name: "StandardProcedure::Workflow", dependent: :destroy

    command :add_contact, :add_group, :add_manager, :add_folder, :add_workflow, :delete_contact, :delete_group, :delete_manager, :delete_folder, :delete_workflow
  end
end
