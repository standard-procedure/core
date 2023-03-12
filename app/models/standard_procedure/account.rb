module StandardProcedure
  class Account < ApplicationRecord
    has_name
    has_logo
    has_many :folders,
             class_name: "StandardProcedure::Folder",
             dependent: :destroy
    include StandardProcedure::Account::Configuration
    include StandardProcedure::Account::Roles
    include StandardProcedure::Account::Organisations
    include StandardProcedure::Account::Workflows
    include StandardProcedure::Account::Templates

    command :add_contact do |group: nil, role: nil, reference: nil, name: nil, **params|
      user = params.delete :performed_by
      group = groups.find_by!(reference: group) if group.is_a? String
      role = roles.find_by!(reference: role) if role.is_a? String
      reference ||= name
      group.add_contact **params.merge(
                          role: role,
                          reference: reference,
                          name: name,
                          performed_by: user,
                        )
    end

    command :remove_contact do |contact:, performed_by:|
      contact.destroy
    end

    def contact_for(user)
      contacts.find_by user: user
    end
  end
end
