module StandardProcedure
  class Workflow < ApplicationRecord
    has_name
    has_fields
    has_reference scope: :account
    belongs_to :account, polymorphic: true
    has_many_references_to :statuses, -> { order :position }, class_name: "StandardProcedure::WorkflowStatus", dependent: :destroy

    command :add_status, :remove_status
  end
end
