module StandardProcedure
  class Organisation < Folder
    has_field_definitions

    def contacts
      Contect.where(id: subtree_ids).order(:name)
    end

    command :add_contact do |name:, reference:, role:, type: nil, performed_by:, **params|
      type ||= "StandardProcedure::Contact"
      folders.create! params.merge(
                        name: name,
                        reference: reference,
                        type: type,
                        role: role,
                      )
    end
  end
end
