module StandardProcedure
  class Organisation < Folder
    has_field_definitions

    def organisations
      Organisation.where(id: subtree_ids).order(:name)
    end

    def contacts
      Contect.where(id: subtree_ids).order(:name)
    end

    command :add_organisation do |name:, reference:, type: nil, performed_by:, **params|
      type ||= "StandardProcedure::Organisation"
      folders.create! params.merge(
                        name: name,
                        reference: reference,
                        type: type,
                        account: self.account,
                      )
    end

    command :add_contact do |name:, reference:, role:, type: nil, performed_by:, **params|
      type ||= "StandardProcedure::Contact"
      role = account.roles.find_by reference: role if role.is_a? String
      folders.create! params.merge(
                        name: name,
                        reference: reference,
                        type: type,
                        role: role,
                        account: self.account,
                      )
    end
  end
end
