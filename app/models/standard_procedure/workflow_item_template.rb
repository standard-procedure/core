module StandardProcedure
  class WorkflowItemTemplate < ApplicationRecord
    has_name
    has_plural
    has_reference
    has_fields
    has_field_definitions
    belongs_to :account, class_name: "StandardProcedure::Account"
    has_many :items, -> { order :position }, class_name: "StandardProcedure::WorkflowItem", dependent: :destroy

    command :add_item, :remove_item
  end
end
