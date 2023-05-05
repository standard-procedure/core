module StandardProcedure
  class FieldDefinition::Checkboxes < FieldDefinition
    serialize :options, Array

    def as_json options = {}
      super options.reverse_merge(only: [:reference, :name, :position, :mandatory, :options])
    end
  end
end
