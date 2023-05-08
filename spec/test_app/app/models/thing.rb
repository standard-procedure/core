class Thing < ApplicationRecord
  has_name
  has_fields
  find_user { |reference| User.find_by reference: reference }
  assign_to { |user| update! assigned_to: user }

  belongs_to :category
  belongs_to :user, optional: true
  belongs_to :assigned_to, class_name: "User", optional: true
  belongs_to :status, class_name: "StandardProcedure::WorkflowStatus", foreign_key: "workflow_status_id", optional: true
  delegate :workflow, to: :status
  has_alerts
end
