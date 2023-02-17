module StandardProcedure
  class Role < ApplicationRecord
    has_name
    has_plural
    has_reference
    has_fields
    belongs_to :account, class_name: "StandardProcedure::Account"
    enum access_level: { standard: 0, restricted: 100, administrator: 1000 }
    has_many :contacts, -> { order :name }, class_name: "StandardProcedure::Contact", dependent: :destroy
    has_many :fields, -> { order :position }, class_name: "StandardProcedure::FieldDefinition", as: :definable, dependent: :destroy
  end
end
