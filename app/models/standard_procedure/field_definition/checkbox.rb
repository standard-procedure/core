module StandardProcedure
  class FieldDefinition::Checkbox < FieldDefinition
    def define_on(instance)
      instance.has_field reader, default: default_value, boolean: true
      instance.singleton_class.validates reader, presence: true if mandatory?
    end
  end
end
