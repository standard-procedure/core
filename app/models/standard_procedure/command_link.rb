module StandardProcedure
  class CommandLink < ApplicationRecord
    belongs_to :command
    belongs_to :item, polymorphic: true
  end
end
