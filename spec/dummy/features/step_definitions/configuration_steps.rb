Given "an online store is configured" do
  @account = StandardProcedure::Account.where(name: "Online Store").first_or_create(active_from: 1.year.ago, active_until: 1.year.from_now)
  @account.configure_from File.open(Rails.root.join("features", "support", "store_configuration.yml")) { |f| f.read }
  @anna = @account.add_contact StandardProcedure::User.root, role: "admin", group: "employees", user: a_saved(StandardProcedure::User, name: "Anna Online-Store")
  @nichola = @account.add_contact StandardProcedure::User.root, role: "staff", group: "employees", user: a_saved(StandardProcedure::User, name: "Nichola Online-Store")
  @api = @account.add_contact StandardProcedure::User.root, role: "api", group: "api_users", user: a_saved(StandardProcedure::User, name: "Online Store API")
  @registry_office_1 = @account.add_contact StandardProcedure::User.root, role: "restricted", group: "suppliers", name: "Registry Office 1", address: "22 Acacia Avenue", postcode: "RN1 8DN"
end

When("the website receives a new standard order to be processed") do
  @customer = @account.add_contact @api, role: "restricted", group: "customers", name: "George Testington", address: "123 Fake Street", postcode: "SP1 1SP"
  @order = @order_processing.add_card @api, card_type: "standard_order", order_number: "123", first_name: "George", last_name: "Testington", product: "Birth Certificate"
end

Then("the order should have a {int} hour deadline set against it") do |int|
  @deadline = @order.deadlines.active.find_by(hours: int)
  expect(@deadline).to_not be_nil
end

Then("the order should have a status of \"%{status}\"") do |status|
  expect(@order.status).to eq status
end

Then("Nichola should be notified about the order") do
  notification = @nichola.notifications.last
  expect(notification).to_not be_nil
  expect(notification.linked_to?(@order)).to eq true
end

When("Nichola logs in") do
  # do nothing
end

Then("she should see the newly received order") do
  expect(@nichola.new_cards).to include(@order)
end

When("she places the order with the supplier") do
  @order.perform_action @nichola, action: "place_order_with_gro", office: @registry_office_1, gro_reference: "ABC123"
end

Then("the previous deadline should be cancelled") do
  @deadline.reload
  expect(@deadline).to be_cancelled
end

When("the order arrives at the office") do
  @order.perform_action @nichola, action: "order_received_from_gro"
end

Then("Nichola prepares the order for delivery and posts it") do
  @order.perform_action @nichola, action: "mark_as_dispatched", dispatch_notes: "Sent via Royal Mail"
end

When("the {int} hour delivery deadline has passed") do |int|
  Timecop.travel int.hours.from_now do
    @account.process_deadlines
  end
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
