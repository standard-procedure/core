When "posts a new standard order in the customer's orders folder" do
  workflow = @account.workflows.find_by reference: "order_processing"
  folder = @customer.folders.find_by name: "Orders"
  template = @account.templates.find_by reference: "order"
  @item =
    template.add_item_to folder: folder,
                         contact: @customer,
                         name: "ORDER101",
                         workflow: workflow,
                         order_number: "123",
                         first_name: "George",
                         last_name: "Testington",
                         product: "Birth Certificate",
                         priority: "Standard",
                         performed_by: @user
end

When("posts a new priority order in the customer's orders folder") do
  workflow = @account.workflows.find_by reference: "order_processing"
  folder = @customer.folders.find_by name: "Orders"
  template = @account.templates.find_by reference: "order"
  @item =
    template.add_item_to folder: folder,
                         contact: @customer,
                         name: "ORDER101",
                         workflow: workflow,
                         order_number: "123",
                         first_name: "George",
                         last_name: "Testington",
                         product: "Birth Certificate",
                         priority: "Priority",
                         performed_by: @user
end

Then("she/he should see the newly received order") do
  expect(@contact.assigned_items).to include(@item)
end

When("she/he places the order with the supplier") do
  @registry_office = @account.contacts.find_by name: "Registry Office 1"
  @item.perform_action action_reference: "place_order_with_gro",
                       office: @registry_office,
                       gro_reference: "ABC123",
                       performed_by: @user
end

When("the order arrives at the office") do
  @item.perform_action action_reference: "order_received_from_gro",
                       performed_by: @user
end

When(
  "{string} prepares the order and posts it as {string} delivery",
) do |name, delivery_type|
  @item.perform_action action_reference: "mark_as_dispatched",
                       dispatch_notes: "Sent via Royal Mail",
                       delivery_type: delivery_type,
                       performed_by: @user
end

When("he/she completes the order") do
  @item.perform_action action_reference: "complete", performed_by: @user
end

When("{string} messages the customer") do |name|
  @message =
    @item.perform_action action_reference: "send_message",
                         recipients: [@customer],
                         subject: "About your order",
                         contents: "I need some more information",
                         reminder_after: 24,
                         performed_by: @user
end

When("the customer replies to say that the order was received") do
  @contact = @user.contacts.first
  @item.perform_action action_reference: "send_message",
                       recipients: [@contact],
                       subject: "Re: About your order",
                       contents: "Here's the information you were after",
                       performed_by: @customer.user
end
