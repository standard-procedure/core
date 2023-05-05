module StandardProcedure
  class FieldDefinition::Dropdown < FieldDefinition
    serialize :options, Array

    def as_json options = {}
      super options.reverse_merge(only: [:reference, :name, :position, :mandatory, :options])
    end
  end
end
