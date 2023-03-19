module StandardProcedure
  class Account < ApplicationRecord
    has_name
    has_logo
    has_many :folders, class_name: "StandardProcedure::Folder", dependent: :destroy
    include StandardProcedure::Account::Configuration
    include StandardProcedure::Account::Roles
    include StandardProcedure::Account::Folders
    include StandardProcedure::Account::Workflows
    include StandardProcedure::Account::Templates

    command :add_contact do |organisation: nil, role: nil, reference: nil, name: nil, **params|
      user = params.delete :performed_by
      if organisation.is_a? String
        organisation = organisations.find_by!(reference: organisation)
      end
      role = roles.find_by!(reference: role) if role.is_a? String
      reference ||= name
      organisation.add_contact(**params.merge(role: role, reference: reference, name: name, performed_by: user))
    end

    command :remove_contact do |contact:, performed_by:|
      contact.destroy
    end

    def contact_for(user)
      contacts.find_by user: user
    end
  end
end
