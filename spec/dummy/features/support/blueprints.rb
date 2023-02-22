when_creating_a User, auto_generate: [:name]

when_creating_a StandardProcedure::Account, auto_generate: [:name], generate: { active_from: -> { 10.days.ago }, active_until: -> { 10.days.from_now } }

when_creating_a StandardProcedure::Role, auto_generate: [:name], generate: { account: -> { a_saved Account } }

when_creating_a StandardProcedure::Group, auto_generate: [:name], generate: { account: -> { a_saved Account } }

when_creating_a StandardProcedure::Contact, generate: { name: -> { 8.random_letters }, reference: -> { 8.random_letters }, user: -> { a_saved User }, role: -> { a_saved Role }, group: -> { a_saved Group } }

def a_saved_contact_called(name, account: nil, group: nil, role: nil)
  user = User.where(name: name).first_or_create
  account ||= a_saved StandardProcedure::Account
  group ||= a_saved StandardProcedure::Group, account: account
  role ||= a_saved StandardProcedure::Role, account: account

  return a_saved StandardProcedure::Contact, name: name, group: group, user: user, role: role
end
