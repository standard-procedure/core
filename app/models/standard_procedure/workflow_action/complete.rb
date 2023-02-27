module StandardProcedure
  class WorkflowAction::Complete < WorkflowAction
    def perform
      item.completed!
    end
  end
end
