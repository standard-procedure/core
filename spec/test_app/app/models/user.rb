class User < ApplicationRecord
  is_user
  has_messages
  has_notifications

  def can? do_something, to_target
    true
  end
end
