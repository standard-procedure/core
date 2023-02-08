module StandardProcedure
  class FieldDefinition < ApplicationRecord
    belongs_to :definable, polymorphic: true
    acts_as_list scope: :definable
    enum visible_to: { all: 0, owner: 1, manager: 2 }, scope: false
    enum editable_by: { all: 0, owner: 1, manager: 2 }, scope: false
  end
end
