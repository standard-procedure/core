When("{string} logs in") do |name|
  @user = StandardProcedure::User.find_by name: name
end
