module StandardProcedure
  class Folder < ApplicationRecord
    has_name
    has_reference scope: :account
    has_fields
    has_ancestry
    belongs_to :account, class_name: "StandardProcedure::Account"
    has_many :items, -> { order :position }, class_name: "StandardProcedure::FolderItem", dependent: :destroy
    has_many :files, -> { order :position }, class_name: "StandardProcedure::File"
    # has_many :slots, -> { order :position}, class_name: "StandardProcedure::Slot"
    # has_many :links, -> { order :position}, class_name: "StandardProcedure::Link"
    has_many_extended :documents, -> { order :position }, class_name: "StandardProcedure::Document"
    before_validation :set_account

    def path_name
      path.collect(&:name).join("/")
    end

    def organisation
      Organisation.where(id: path_ids).last
    end

    def contact
      Contact.where(id: path_ids).last
    end

    def organisations
      Organisation.where(id: subtree_ids).order(:name)
    end

    def contacts
      Contact.where(id: subtree_ids).order(:name)
    end

    def folders
      Folder.where(id: child_ids).order(:name)
    end

    command :add_folder do |name: nil, reference: nil, performed_by: nil|
      account.add_folder parent: self, name: name, reference: reference, performed_by: performed_by
    end

    command :delete do |performed_by: nil|
      account.remove_folder folder: self, performed_by: performed_by
    end

    command :upload_file do |name:, io:, performed_by:|
      files.create!(name: name).tap { |f| f.file.attach io: io, filename: name }
    end

    command :create_document do |name:, performed_by:, reference: nil, template: nil, workflow: nil, status: nil, **params|
      template = account.templates.find_by(reference: template) if template.is_a? String
      template.create_document reference: reference, name: name, folder: self, workflow: workflow, status: status, performed_by: performed_by, **params
    end

    def is_organisation?
      is_a? Organisation
    end

    def is_contact?
      is_a? Contact
    end

    protected

    def set_account
      self.account ||= parent.account
    end
  end
end
