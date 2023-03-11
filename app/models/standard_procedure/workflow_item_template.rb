module StandardProcedure
  class WorkflowItemTemplate < ApplicationRecord
    has_name
    has_plural
    has_reference
    has_fields
    has_field_definitions
    belongs_to :account, class_name: "StandardProcedure::Account"
    has_many :items,
             -> { order :position },
             class_name: "StandardProcedure::WorkflowItem",
             foreign_key: "template_id",
             dependent: :destroy

    def build_item
      items.build.with_fields_from(field_definitions)
    end

    command :add_item do |workflow: nil, status: nil, group: nil, contact: nil, **params|
      user = params.delete :performed_by
      status ||= workflow.statuses.first
      group ||= contact.group
      build_item.tap do |item|
        item.update! params.merge(
                       status: status,
                       group: group,
                       contact: contact,
                     )
        item.status.item_added(item: item, performed_by: user)
      end
    end
    command :remove_item
  end
end
