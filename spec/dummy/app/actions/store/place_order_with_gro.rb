module Store
  class PlaceOrderWithGro < StandardProcedure::WorkflowAction
    has_model :office, "StandardProcedure::Group"
    has_field :gro_reference
    validates :office, presence: true
    validates :gro_reference, presence: true

    def perform
      item.set_status user, reference: "order_placed"
    end
  end
end
