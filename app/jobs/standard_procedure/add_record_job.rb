module StandardProcedure
  class AddRecordJob < ApplicationJob
    def perform parent, association, user:, **params
      parent.send(association).create! params
    end
  end
end
