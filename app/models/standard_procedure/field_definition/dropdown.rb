module StandardProcedure
  class FieldDefinition::Dropdown < FieldDefinition
    has_array :options
    def as_json options = {}
      super options.reverse_merge(only: [:reference, :name, :position, :mandatory, :options])
    end
  end
end
