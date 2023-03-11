module Store
  class PlaceOrderWithGro < StandardProcedure::WorkflowAction
    has_model :office, "StandardProcedure::Group"
    has_field :gro_reference
    validates :office, presence: true
    validates :gro_reference, presence: true

    def perform
      item.set_status reference: "order_placed", performed_by: performed_by
    end
  end
end
