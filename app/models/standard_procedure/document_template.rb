module StandardProcedure
  class DocumentTemplate < ApplicationRecord
    has_name
    has_plural
    has_reference
    has_fields
    has_field_definitions
    belongs_to :account, class_name: "StandardProcedure::Account"
    has_many :items,
             -> { order :position },
             class_name: "StandardProcedure:Document",
             foreign_key: "template_id",
             dependent: :destroy

    command :remove_item
  end
end
