module StandardProcedure
  class Group < ApplicationRecord
    has_name
    has_plural
    has_reference
    has_fields
    has_array :group_folder_permissions
    has_array :member_folder_permissions
    has_array :field_definitions
    belongs_to :account, class_name: "StandardProcedure::Account"
    has_many :contacts, class_name: "StandardProcedure::Contact", dependent: :destroy

    command :add_contact, :remove_contact
  end
end
