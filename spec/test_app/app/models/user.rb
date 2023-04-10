class User < ApplicationRecord
  is_user

  def can? do_something, to_target
    true
  end
end
