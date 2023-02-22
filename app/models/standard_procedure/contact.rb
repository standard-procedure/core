module StandardProcedure
  class Contact < ApplicationRecord
    has_fields
    has_reference
    belongs_to :user, class_name: "StandardProcedure::User", optional: true
    belongs_to :group, class_name: "StandardProcedure::Group"
    belongs_to :role, class_name: "StandardProcedure::Role"
    has_many :items, -> { order :name }, class_name: "StandardProcedure::WorkflowItem", foreign_key: "contact_id", dependent: :destroy
    has_many :assigned_items, -> { order :name }, class_name: "StandardProcedure::WorkflowItem", foreign_key: "assigned_to_id", dependent: :destroy
    has_many :notifications, -> { order :acknowledged_at }, class_name: "StandardProcedure::Notification", dependent: :destroy
    has_and_belongs_to_many :alerts, class_name: "StandardProcedure::Alert"
    delegate :account, to: :role
    delegate :access_level, to: :role

    def set_reference
      self.reference = user.reference if reference.blank? && user.present?
    end
  end
end
