module StandardProcedure
  class FieldDefinition < ApplicationRecord
    belongs_to :definable, polymorphic: true
    acts_as_list scope: :definable
    has_name
    has_reference scope: :definable
    has_fields
    has_field :default_value
    has_field :calculated_value
    enum :visible_to, %i[all owner manager], prefix: true, scopes: false
    enum :editable_by, %i[all owner manager], prefix: true, scopes: false

    def reader
      @reader ||= reference.parameterize(separator: "_").to_sym
    end

    def define_on(instance)
      instance.has_field reader, default: default_value
      instance.singleton_class.validates reader, presence: true if mandatory?
    end

    def as_json options = {}
      super options.reverse_merge(only: [:reference, :name, :position, :mandatory])
    end
  end
end
