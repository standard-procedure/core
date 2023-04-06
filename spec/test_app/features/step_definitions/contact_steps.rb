When "creates a new {string} called {string} in the {string} group" do |role, name, group|
  @customer =
    @account.add_contact role: role,
      group: group,
      name: name,
      performed_by: @user
end
