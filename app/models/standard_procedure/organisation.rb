module StandardProcedure
  class Organisation < Folder
    has_field_definitions

    command :add_organisation do |name:, performed_by:, reference: nil, type: nil, **params|
      type ||= "StandardProcedure::Organisation"
      organisation_class = type.constantize
      organisation_class.create!(**params.merge(parent: self, name: name, account: account))
    end

    command :add_contact do |name:, role:, performed_by:, reference: nil, type: nil, **params|
      type ||= "StandardProcedure::Contact"
      contact_class = type.constantize

      role = account.roles.find_by reference: role if role.is_a? String
      contact_class.create_with_fields_from!(role, **params.merge(parent: self, name: name, reference: reference, role: role, account: account))
    end
  end
end
