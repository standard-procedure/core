When("the website receives a new standard order to be processed") do
  @customer = @account.add_contact @user, role: "customer", group: "customers", name: "George Testington" #, address: "123 Fake Street", postcode: "SP1 1SP"
  @card = @order_processing.add_card @user, customer: @customer, card_type: "standard_order" #, order_number: "123", first_name: "George", last_name: "Testington", product: "Birth Certificate"
end

Then("Nichola should be notified about the order") do
  @api = @account.contacts.find_by name: "Nichola Online-Store"

  notification = @nichola.notifications.last
  expect(notification).to_not be_nil
  expect(notification.linked_to?(@order)).to eq true
end

Then("she should see the newly received order") do
  expect(@nichola.new_cards).to include(@order)
end

When("she places the order with the supplier") do
  @card.perform_action @nichola, action: "place_order_with_gro", office: @registry_office_1, gro_reference: "ABC123"
end

When("the order arrives at the office") do
  @card.perform_action @nichola, action: "order_received_from_gro"
end

Then("{string} prepares the order for delivery and posts it") do |name|
  @card.perform_action @nichola, action: "mark_as_dispatched", dispatch_notes: "Sent via Royal Mail"
end

Then("{string} should be notified") do |name|
  # do nothing
end

When("the website receives a new priority order to be processed") do
  # do nothing
end

Then("{string} prepares the order for delivery and posts it") do |name|
  # do nothing
end

Then("a new deadline of {int} day should be set against the order") do |int|
  # do nothing
end

Then("{string} should receive a notification") do |name|
  # do nothing
end

Then("she records the delivery details, marking the order as {string}") do |string|
  # do nothing
end
