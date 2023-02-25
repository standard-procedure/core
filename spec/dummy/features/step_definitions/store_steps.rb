When("the website receives a new standard order to be processed") do
  @customer = @account.add_contact @user, role: "customer", group: "customers", name: "George Testington" #, address: "123 Fake Street", postcode: "SP1 1SP"
  @order_processing = @account.workflows.find_by reference: "order_processing"
  @item = @order_processing.add_item @user, contact: @customer, template: "order", name: "ORDER101", workflow: @order_processing #, order_number: "123", first_name: "George", last_name: "Testington", product: "Birth Certificate"
end

Then("she/he should see the newly received order") do
  expect(@contact.assigned_items).to include(@item)
end

When("she/he places the order with the supplier") do
  @registry_office = @account.contacts.find_by name: "Registry Office 1"
  @item.perform_action @user, action_reference: "place_order_with_gro", office: @registry_office, gro_reference: "ABC123"
end

When("the order arrives at the office") do
  @item.perform_action @user, action_reference: "order_received_from_gro"
end

Then("{string} prepares the order for delivery and posts it") do |name|
  @item.perform_action @user, action_reference: "mark_as_dispatched", dispatch_notes: "Sent via Royal Mail"
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
