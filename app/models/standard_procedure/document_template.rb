module StandardProcedure
  class DocumentTemplate < ApplicationRecord
    has_name
    has_plural
    has_reference
    has_fields
    has_field_definitions
    belongs_to :account, class_name: "StandardProcedure::Account"
    has_many :items,
      -> { order :position },
      class_name: "StandardProcedure:Document",
      foreign_key: "template_id",
      dependent: :destroy

    command :create_document do |name:, folder:, performed_by:, reference: nil, workflow: nil, status: nil, **params|
      if workflow.is_a? String
        workflow =
          account.workflows.find_by(reference: workflow)
      end
      if workflow.present? &&
          status.is_a?(String)
        status =
          workflow.statuses.find_by(reference: status)
      end
      status ||= workflow.statuses.first
      document =
        folder.documents.build name: name,
          reference: reference,
          type: item_type,
          status: status,
          template: self
      document
        .with_fields_from(field_definitions)
        .tap do |d|
          d.update! params
          status&.document_added document: d, performed_by: performed_by
        end
    end

    command :remove_item
  end
end