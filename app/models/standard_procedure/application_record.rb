require "acts_as_list"

module StandardProcedure
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
