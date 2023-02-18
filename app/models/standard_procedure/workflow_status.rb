module StandardProcedure
  class WorkflowStatus < ApplicationRecord
    has_name
    has_reference
    has_fields
    belongs_to :workflow, class_name: "StandardProcedure::Workflow"
    has_many :items, class_name: "StandardProcedure::WorkflowItem", dependent: :destroy
    acts_as_list scope: :workflow
    delegate :account, to: :workflow

    command :add_item, :remove_item
  end
end
