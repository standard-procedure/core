module StandardProcedure
  class Organisation < Folder
    has_field_definitions

    command :add_organisation do |name:, performed_by:, reference: nil, type: nil, **params|
      type ||= "StandardProcedure::Organisation"
      folders.where(reference: reference).first_or_create! params.merge(name: name, type: type, account: account)
    end

    command :add_contact do |name:, role:, performed_by:, reference: nil, type: nil, **params|
      type ||= "StandardProcedure::Contact"
      role = account.roles.find_by reference: role if role.is_a? String
      folders.where(reference: reference).first_or_create! params.merge(name: name, reference: reference, role: role, type: type, account: account)
    end
  end
end
