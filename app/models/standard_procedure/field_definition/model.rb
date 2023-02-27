module StandardProcedure
  class FieldDefinition::Model < FieldDefinition
    has_field :model_type
    validates :model_type, presence: true
    has_field :options, default: ""

    def define_on(instance)
      instance.has_model reader, model_type
    end
  end
end
