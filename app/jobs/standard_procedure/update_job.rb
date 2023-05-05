class StandardProcedure::UpdateJob < ApplicationJob
  def perform model, user:, **params
    model.update! params
  end
end
