class Thing < ApplicationRecord
  has_name
  has_fields
  belongs_to :category
  belongs_to :user, optional: true
  belongs_to :status, class_name: "StandardProcedure::WorkflowStatus", foreign_key: "workflow_status_id", optional: true
end
