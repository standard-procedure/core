When("{string} logs in") do |name|
  @user = StandardProcedure::User.find_by name: name
  @contact = @user.contacts.first
end

Then("{string} should be notified") do |name|
  contact = @account.contacts.find_by name: name

  notification = contact.notifications.last
  expect(notification).to_not be_nil
  expect(notification.linked_to?(@item)).to eq true
end
