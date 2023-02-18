class User < StandardProcedure::User
  def can?(perform_action, target)
    true
  end
end
