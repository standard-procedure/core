module StandardProcedure
  class Workflow < ApplicationRecord
    has_name
    has_fields
    has_reference scope: :account
    belongs_to :account, polymorphic: true, optional: true
    has_many_references_to :statuses, -> { order :position }, class_name: "StandardProcedure::WorkflowStatus", dependent: :destroy

    def initial_status
      statuses.first
    end

    def add_status user:, **params
      AddRecordJob.perform_now self, :statuses, **params
    end

    def remove_status user:, status:
      DeleteJob.perform_now status, user: user
    end
  end
end
