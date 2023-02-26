module StandardProcedure
  class FieldDefinition::Model < FieldDefinition
    has_field :model_class
    validates :model_class, presence: true

    def define_on(instance)
      instance.has_model reader, model_class
    end
  end
end
