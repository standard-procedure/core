class DateTime
  class << self
    def end_of_time
      @end_of_time ||= Date.end_of_time.to_datetime
    end

    def beginning_of_time
      @beginning_of_time ||= Date.beginning_of_time.to_datetime
    end
  end
end
