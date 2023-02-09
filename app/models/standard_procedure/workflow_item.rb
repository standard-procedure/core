module StandardProcedure
  class WorkflowItem < ApplicationRecord
    has_name
    has_reference
    has_fields
    belongs_to :status, class_name: "StandardProcedure::WorkflowStatus"
    has_and_belongs_to_many :folder_items, class_name: "StandardProcedure::FolderItem", join_table: "standard_procedure_related_items", foreign_key: "workflow_item_id", association_foreign_key: "folder_item_id"

    command :add_folder_item, :remove_folder_item
  end
end
