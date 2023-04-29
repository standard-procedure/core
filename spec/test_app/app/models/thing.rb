class Thing < ApplicationRecord
  has_name
  has_fields
  find_workflow_users_with :find_contact_from

  belongs_to :category
  belongs_to :user, optional: true
  belongs_to :assigned_to, class_name: "User", optional: true
  belongs_to :status, class_name: "StandardProcedure::WorkflowStatus", foreign_key: "workflow_status_id", optional: true
  has_alerts
  # Workflow Methods
  def find_contact_from reference
    User.find_by reference: reference
  end

  def assign_to user:, performed_by:
    update! assigned_to: user
  end
end
