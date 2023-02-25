module StandardProcedure
  class WorkflowAction < ApplicationRecord
    has_fields 
    belongs_to :user, class_name: "StandardProcedure::User"
    belongs_to :item, class_name: "StandardProcedure::WorkflowItem"
    has_hash :configuration 
    after_create :perform 

    def perform 
      raise "Not yet implemented"
    end

    # Do any initialisation
    # Used by StandardProcedure::WorkflowAction::UserDefined to load up user-defined fields
    def prepare 
      self
    end
  end
end
