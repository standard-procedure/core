module StandardProcedure
  class WorkflowItem < ApplicationRecord
    has_name
    has_reference
    has_fields
    belongs_to :template, class_name: "StandardProcedure::WorkflowItemTemplate"
    belongs_to :status, class_name: "StandardProcedure::WorkflowStatus"
    belongs_to :group, class_name: "StandardProcedure::Group"
    belongs_to :contact, class_name: "StandardProcedure::Contact", optional: true
    has_many :alerts, -> { order :due_at }, class_name: "StandardProcedure::Alert", as: :item, dependent: :destroy
    delegate :account, to: :status
    has_and_belongs_to_many :folder_items, class_name: "StandardProcedure::FolderItem", join_table: "standard_procedure_related_items", foreign_key: "workflow_item_id", association_foreign_key: "folder_item_id"
    acts_as_list scope: :status

    command :add_alert
  end
end
