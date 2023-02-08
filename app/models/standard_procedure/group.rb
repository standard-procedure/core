module StandardProcedure
  class Group < ApplicationRecord
    has_name
    has_plural
    has_reference
    has_fields
    belongs_to :account, class_name: "StandardProcedure::Account"
    has_many :contacts, class_name: "StandardProcedure::Contact", dependent: :destroy

    command :add_contact, :remove_contact
  end
end
