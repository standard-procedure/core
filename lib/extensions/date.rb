class Date
  class << self
    def end_of_time
      @end_of_time ||= Date.new(3000, 1, 1)
    end

    def beginning_of_time
      @beginning_of_time ||= Date.new(1900, 1, 1)
    end
  end
end
