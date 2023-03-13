module StandardProcedure
  class File < FolderItem
    has_one_attached :file
  end
end
