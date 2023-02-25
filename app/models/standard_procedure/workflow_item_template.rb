module StandardProcedure
  class WorkflowItemTemplate < ApplicationRecord
    has_name
    has_plural
    has_reference
    has_fields
    has_field_definitions
    belongs_to :account, class_name: "StandardProcedure::Account"
    has_many :items, -> { order :position }, class_name: "StandardProcedure::WorkflowItem", foreign_key: "template_id", dependent: :destroy

    def build_item
      items.build.with_fields_from(self.fields)
    end

    command :add_item do |user, **params|
      params[:status] ||= params.delete(:workflow).statuses.first
      params[:group] ||= params[:contact].group
      build_item.tap do |item|
        item.update! params 
        item.status.item_added(user, item: item)
      end
    end
    command :remove_item
  end
end
