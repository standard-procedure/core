module StandardProcedure
  class Document < FolderItem
    belongs_to :template, class_name: "StandardProcedure::WorkflowItemTemplate"
  end
end
