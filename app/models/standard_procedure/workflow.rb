module StandardProcedure
  class Workflow < ApplicationRecord
    has_name
    has_reference
    has_fields
    belongs_to :account, class_name: "StandardProcedure::Account"
    has_many :statuses,
      -> { order :position },
      class_name: "StandardProcedure::WorkflowStatus",
      dependent: :destroy

    command :add_status, :remove_status

    command :add_item do |template: nil, **params|
      user = params.delete :performed_by
      if template.is_a? String
        template =
          account.templates.find_by(reference: template)
      end
      template.add_item performed_by: user, **params
    end

    def status(reference)
      statuses.find_by reference: reference
    end
  end
end
