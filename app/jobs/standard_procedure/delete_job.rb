module StandardProdedure
  class DeleteJob < ApplicationJob
    def perform model, user:
      model.destroy
    end
  end
end
