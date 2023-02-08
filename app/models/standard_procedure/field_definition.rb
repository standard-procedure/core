module StandardProcedure
  class FieldDefinition < ApplicationRecord
    belongs_to :definable, polymorphic: true
    acts_as_list scope: :definable
    enum :visible_to, [:all, :owner, :manager], prefix: true, scopes: false
    enum :editable_by, [:all, :owner, :manager], prefix: true, scopes: false
  end
end
