module StandardProcedure
  class Notification::MessageReceived < Notification
    def message
      linked("StandardProcedure::Message").first
    end
  end
end
