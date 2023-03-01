module StandardProcedure
  class Account < ApplicationRecord
    has_name
    has_logo
    has_many :folders, class_name: "StandardProcedure::Folder", dependent: :destroy
    include StandardProcedure::Account::Configuration
    include StandardProcedure::Account::Roles
    include StandardProcedure::Account::Groups
    include StandardProcedure::Account::Workflows
    include StandardProcedure::Account::Templates

    command :add_contact do |user, group: nil, role: nil, reference: nil, name: nil, **params|
      group = groups.find_by!(reference: group) if group.is_a? String
      role = roles.find_by!(reference: role) if role.is_a? String
      reference ||= name
      group.add_contact user, **params.merge(role: role, reference: reference, name: name)
    end

    command :remove_contact do |user, contact: nil|
      params[:contact].destroy
    end

    def contact_for(user)
      contacts.find_by user: user
    end
  end
end
