When("posts a new standard order to be processed") do
  @customer = @account.add_contact @user, role: "customer", group: "customers", name: "George Testington" #, address: "123 Fake Street", postcode: "SP1 1SP"
  @order_processing = @account.workflows.find_by reference: "order_processing"
  @item = @order_processing.add_item @user, contact: @customer, template: "order", name: "ORDER101", workflow: @order_processing, order_number: "123", first_name: "George", last_name: "Testington", product: "Birth Certificate", priority: "Standard"
end

When("posts a new priority order to be processed") do
  @customer = @account.add_contact @user, role: "customer", group: "customers", name: "George Testington" #, address: "123 Fake Street", postcode: "SP1 1SP"
  @order_processing = @account.workflows.find_by reference: "order_processing"
  @item = @order_processing.add_item @user, contact: @customer, template: "order", name: "ORDER101", workflow: @order_processing, order_number: "123", first_name: "George", last_name: "Testington", product: "Birth Certificate", priority: "Priority"
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

When("{string} prepares the order and posts it as {string} delivery") do |name, delivery_type|
  @item.perform_action @user, action_reference: "mark_as_dispatched", dispatch_notes: "Sent via Royal Mail", delivery_type: delivery_type
end

When("he/she completes the order") do
  @item.perform_action @user, action_reference: "complete"
end

When("{string} messages the customer") do |name|
  @message = @item.perform_action @user, action_reference: "send_message", recipients: [@customer], subject: "About your order", contents: "I need some more information", reminder_after: 24
end

When("the customer replies to say that the order was received") do
  @contact = @user.contacts.first
  @item.perform_action @customer.user, action_reference: "send_message", recipients: [@contact], subject: "Re: About your order", contents: "Here's the information you were after"
end
