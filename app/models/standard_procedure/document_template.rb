module StandardProcedure
  class DocumentTemplate < ApplicationRecord
    has_name
    has_plural
    has_reference
    has_fields
    has_field_definitions
    belongs_to :account, class_name: "StandardProcedure::Account"
    has_many_extended :documents, -> { order :position }, class_name: "StandardProcedure:Document", foreign_key: "template_id", dependent: :destroy

    command :create_document do |name:, folder:, performed_by:, reference: nil, workflow: nil, status: nil, **params|
      document = folder.documents.find_by(reference: reference)
      return document unless document.blank?

      workflow = account.workflows.find_by(reference: workflow) if workflow.is_a? String
      status = workflow.statuses.find_by(reference: status) if workflow.present? && status.is_a?(String)
      status ||= workflow.statuses.first

      item_class.create_with_fields_from!(self, **params.merge(folder: folder, name: name, reference: reference, type: item_type, status: status, template: self)).tap do |document|
        status&.document_added document: document, performed_by: performed_by
      end
    end

    command :remove_document

    protected

    def item_class
      @item_class ||= item_type.constantize
    end
  end
end
