module StandardProcedure
  class Workflow < ApplicationRecord
    has_name
    has_reference
    has_fields
    belongs_to :account, class_name: "StandardProcedure::Account"
    has_many :statuses, class_name: "StandardProcedure::WorkflowStatus", dependent: :destroy

    command :add_status, :remove_status

    command :add_item do |user, **params|
      template = params.delete(:template)
      template = account.templates.find_by(reference: template) if template.is_a? String
      template.add_item user, **params
    end
  end
end
