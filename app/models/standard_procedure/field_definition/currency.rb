module StandardProcedure
  class FieldDefinition::Currency < FieldDefinition::Decimal
    has_field :currency, default: "GBP"

    def as_json options = {}
      super options.reverse_merge(only: [:reference, :name, :position, :mandatory, :currency])
    end
  end
end
