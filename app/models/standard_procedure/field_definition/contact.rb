module StandardProcedure
  class FieldDefinition::Contact < FieldDefinition::Model
    before_validation :set_model_type

    protected

    def set_model_type
      self.model_type ||= "StandardProcedure::Contact"
    end
  end
end
