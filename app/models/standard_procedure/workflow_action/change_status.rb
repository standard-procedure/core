module StandardProcedure
  class WorkflowAction::ChangeStatus < WorkflowAction
    has_model :status, "StandardProcedure::WorkflowStatus"
    validates :status, presence: true

    def perform
      update_status
    end

    def update_status
      item.update status: self.status
      status.item_added(item: item, performed_by: performed_by)
    end
  end
end
