module StandardProcedure
  class WorkflowItemTemplate < ApplicationRecord
    has_name
    has_plural
    has_reference
    has_fields
    has_field_definitions
    belongs_to :account, class_name: "StandardProcedure::Account"
    has_many :items, -> { order :position }, class_name: "StandardProcedure::WorkflowItem", foreign_key: "template_id", dependent: :destroy

    command :add_item do |user, **params|
      params[:status] ||= params.delete(:workflow).statuses.first
      params[:group] ||= params[:contact].group
      items.create! params
    end
    command :remove_item
  end
end
