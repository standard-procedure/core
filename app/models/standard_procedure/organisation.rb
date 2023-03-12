module StandardProcedure
  class Organisation < Folder
    has_field_definitions

    def contacts
      Contect.where(id: descendant_ids)
    end
  end
end
