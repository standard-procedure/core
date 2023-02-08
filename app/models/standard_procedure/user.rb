module StandardProcedure
  class User < ApplicationRecord
    has_reference
    has_name
  end
end
