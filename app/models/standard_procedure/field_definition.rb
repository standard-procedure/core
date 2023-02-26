module StandardProcedure
  class FieldDefinition < ApplicationRecord
    belongs_to :definable, polymorphic: true
    acts_as_list scope: :definable
    has_name
    has_reference
    has_fields
    has_field :default_value
    has_field :calculated_value
    enum :visible_to, [:all, :owner, :manager], prefix: true, scopes: false
    enum :editable_by, [:all, :owner, :manager], prefix: true, scopes: false

    def reader
      @reader ||= reference.parameterize(separator: "_").to_sym
    end

    def define_on(instance)
      instance.has_field reader, default: default_value
      instance.singleton_class.validates reader, presence: true if mandatory?
    end
  end
end
