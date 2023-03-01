module StandardProcedure
  class Group < ApplicationRecord
    has_name
    has_plural
    has_reference
    has_fields
    has_field_definitions
    belongs_to :account, class_name: "StandardProcedure::Account"
    has_many :contacts, -> { order :name }, class_name: "StandardProcedure::Contact", dependent: :destroy

    command :add_contact do |current_user, user: nil, role: nil, reference: nil, name: nil, type: nil, **params|
      user ||= User.where(reference: reference).first_or_create(name: name) unless reference.blank?
      contacts.create! params.merge(user: user, role: role, reference: reference, name: name)
    end

    command :remove_contact
  end
end
