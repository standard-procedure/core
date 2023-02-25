module StandardProcedure
  class WorkflowAction::ChangeStatus < WorkflowAction
    has_model :status, "StandardProcedure::WorkflowStatus"
    validates :status, presence: true 

    def perform 
      item.update status: self.status
    end
  end
end
