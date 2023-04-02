module StandardProcedure
  class FieldDefinition::Organisation < FieldDefinition::Model
    before_validation :set_model_type

    protected

    def set_model_type
      self.model_type ||= "StandardProcedure::Organisation"
    end
  end
end
