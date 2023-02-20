Given "an account called {string} loaded from {string}" do |name, config_file|
  @account = StandardProcedure::Account.where(name: name).first_or_create(active_from: 1.year.ago, active_until: 1.year.from_now)
  @account.configure_from File.open(Rails.root.join("features", "support", config_file)) { |f| f.read }
end

Given "{string} has a/an {string} account in the {string} group" do |name, role, group|
  email = "#{name.parameterize}@example.com"
  @account.add_contact StandardProcedure::User.root, role: role, group: group, name: name, reference: email, user: a_saved(User, name: name, reference: email)
end
