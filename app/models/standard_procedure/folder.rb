module StandardProcedure
  class Folder < ApplicationRecord
    has_name
    has_reference
    has_fields
    has_ancestry
    belongs_to :account, class_name: "StandardProcedure::Account"
    has_many :items,
             -> { order :position },
             class_name: "StandardProcedure::FolderItem",
             dependent: :destroy
    has_many :files,
             -> { order :position },
             class_name: "StandardProcedure::File"
    # has_many :slots, -> { order :position}, class_name: "StandardProcedure::Slot"
    # has_many :links, -> { order :position}, class_name: "StandardProcedure::Link"
    has_many :documents,
             -> { order :position },
             class_name: "StandardProcedure::Document"

    def organisation
      Organisation.where(id: ancestor_ids).first
    end

    def contact
      Contact.where(id: ancestor_ids).first
    end

    def folders
      children
    end

    command :upload_file do |name:, io:, performed_by:|
      files.create!(name: name).tap { |f| f.file.attach io: io, filename: name }
    end

    command :create_document do |name:, template: nil, workflow: nil, status: nil, performed_by:, **params|
      template.create_document name: name,
                               folder: self,
                               workflow: workflow,
                               status: status,
                               performed_by: performed_by,
                               **params
    end
  end
end
