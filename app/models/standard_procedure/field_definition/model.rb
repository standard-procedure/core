module StandardProcedure
  class FieldDefinition::Model < FieldDefinition
    has_field :model_type
    validates :model_type, presence: true
    has_field :options, default: ""

    def define_on(instance)
      instance.has_model reader, model_type
    end

    def as_json options = {}
      super options.reverse_merge(only: [:reference, :name, :position, :mandatory, :model_type, :options])
    end
  end
end
