module StandardProcedure
  class WorkflowAction::CompleteJob < ApplicationJob
    def perform document, user:
      document.completed!
    end
  end
end
