module StandardProcedure
  class Notification::AlertReceived < Notification
    def alert
      linked("StandardProcedure::Alert").first
    end
  end
end
