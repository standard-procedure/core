module StandardProcedure
  class FieldDefinition::Currency < FieldDefinition::Decimal
    has_field :currency, default: "GBP"
  end
end
