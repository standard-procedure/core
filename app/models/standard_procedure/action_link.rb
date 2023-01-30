module StandardProcedure
  class ActionLink < ApplicationRecord
    belongs_to :action
    belongs_to :item, polymorphic: true
  end
end
