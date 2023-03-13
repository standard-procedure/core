when_creating_a User, auto_generate: [:name]
when_creating_a StandardProcedure::User, auto_generate: [:name]

when_creating_a StandardProcedure::Account,
                auto_generate: [:name],
                generate: {
                  active_from: -> { 10.days.ago },
                  active_until: -> { 10.days.from_now },
                }

when_creating_a StandardProcedure::Role,
                auto_generate: [:name],
                generate: {
                  account: -> { a_saved StandardProcedure::Account },
                }

when_creating_a StandardProcedure::Folder,
                auto_generate: [:name],
                generate: {
                  account: -> { a_saved StandardProcedure::Account },
                }

when_creating_a StandardProcedure::Organisation,
                auto_generate: [:name],
                generate: {
                  account: -> { a_saved StandardProcedure::Account },
                }
when_creating_a StandardProcedure::Contact,
                generate: {
                  name: -> { 8.random_letters },
                  reference: -> { 8.random_letters },
                  parent: -> { a_saved StandardProcedure::Organisation },
                  role: -> { a_saved StandardProcedure::Role },
                }

def a_saved_contact_called(
  name,
  reference: nil,
  account: nil,
  organisation: nil,
  role: nil,
  user: nil
)
  reference ||= name
  user ||= StandardProcedure::User.where(name: name).first_or_create
  account ||= a_saved StandardProcedure::Account
  organisation ||= a_saved StandardProcedure::Organisation, account: account
  role ||= a_saved StandardProcedure::Role, account: account

  return(
    a_saved StandardProcedure::Contact,
            account: account,
            parent: organisation,
            name: name,
            reference: reference,
            user: user,
            role: role
  )
end

when_creating_a StandardProcedure::Workflow,
                auto_generate: [:name],
                generate: {
                  account: -> { a_saved StandardProcedure::Account },
                }
when_creating_a StandardProcedure::DocumentTemplate,
                auto_generate: [:name],
                generate: {
                  account: -> { a_saved StandardProcedure::Account },
                }
when_creating_a StandardProcedure::WorkflowStatus,
                auto_generate: [:name],
                generate: {
                  workflow: -> { a_saved StandardProcedure::Workflow },
                }
when_creating_a StandardProcedure::Document,
                auto_generate: [:name],
                generate: {
                  template: -> { a_saved StandardProcedure::DocumentTemplate },
                }

def a_saved_document_titled(
  name,
  reference: nil,
  account: nil,
  status: nil,
  workflow: nil,
  template: nil,
  contact: nil,
  organisation: nil
)
  account ||= a_saved StandardProcedure::Account
  template ||= a_saved StandardProcedure::DocumentTemplate, account: account
  organisation ||= a_saved StandardProcedure::Organisation, account: account
  contact ||=
    a_saved_contact_called "Someone",
                           account: account,
                           organisation: organisation
  workflow ||= a_saved StandardProcedure::Workflow, account: account
  status ||=
    workflow.statuses.first ||
      a_saved(StandardProcedure::WorkflowStatus, workflow: workflow)
  return(
    a_saved StandardProcedure::Document,
            name: name,
            reference: reference,
            template: template,
            status: status,
            folder: contact
  )
end
