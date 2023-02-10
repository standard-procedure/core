Given "an online store is configured" do
  @account = StandardProcedure::Account.where(name: "Online Store").first_or_create(active_from: 1.year.ago, active_until: 1.year.from_now)
  @account.configure_from File.open(Rails.root.join("features", "support", "store_configuration.yml")) { |f| f.read }
  @anna = @account.add_contact StandardProcedure::User.root, group: "employees", user: a_saved(StandardProcedure::User, name: "Anna Online-Store")
  @nichola = @account.add_contact StandardProcedure::User.root, group: "employees", user: a_saved(StandardProcedure::User, name: "Nichola Online-Store")
  @api = @account.add_contact StandardProcedure::User.root, group: "api_users", user: a_saved(StandardProcedure::User, name: "Online Store API")
end

When("the website receives a new standard order to be processed") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the order should have a {int} hour deadline set against it") do |int|
  # Then('the order should have a {float} hour deadline set against it') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then("Nichola should be notified") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("Nichola logs in") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("she should see the newly received order") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("she places the order with the supplier") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("records the supplier information, marking the order as requiring {string}") do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the order should marked as {string}") do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the previous deadline should be cancelled") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("a new deadline of {int} days set against the order") do |int|
  # Then('a new deadline of {float} days set against the order') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

When("the order arrives at the office") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("Nichola prepares the order for delivery and posts it") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("she records the delivery details, marking the order as {string}") do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the order should be marked as {string}") do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

When("the {int} day delivery deadline has passed") do |int|
  # When('the {float} day delivery deadline has passed') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

When("the {int} hour deadline has passed") do |int|
  # When('the {float} hour deadline has passed') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then("Anna should be notified") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("the website receives a new priority order to be processed") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("Anna logs in") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("a new deadline of {int} day set against the order") do |int|
  # Then('a new deadline of {float} day set against the order') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then("Anna prepares the order for delivery and posts it") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("a new deadline of {int} day should be set against the order") do |int|
  # Then('a new deadline of {float} day should be set against the order') do |float|
  pending # Write code here that turns the phrase above into concrete actions
end

Then("Anna should receive a notification") do
  pending # Write code here that turns the phrase above into concrete actions
end
