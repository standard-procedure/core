class User < StandardProcedure::User
  def can?(perform_command, target)
    true
  end
end
