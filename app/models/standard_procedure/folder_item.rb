module StandardProcedure
  class FolderItem < ApplicationRecord
    has_name
    has_reference
    has_fields
    belongs_to :folder, class_name: "StandardProcedure::Folder"
    has_and_belongs_to_many :documents,
      class_name: "StandardProcedure::Document",
      join_table: "standard_procedure_related_items",
      association_foreign_key: "document_id",
      foreign_key: "folder_item_id"
    acts_as_list scope: :folder
    delegate :account, to: :folder
    delegate :organisation, to: :folder
    delegate :contact, to: :folder
  end
end
