module StandardProcedure
  class User < ApplicationRecord
    is_user
    has_reference
    has_name
    has_many :contacts,
      class_name: "StandardProcedure::Contact",
      dependent: :destroy

    command :attach do |access_code:, performed_by:|
      Contact.find_by!(access_code: access_code).update user: self
    end

    command :amend do |**params|
      user = params.delete(:performed_by)
      update! params
      contacts.each { |c| c.amend name: name, performed_by: user }
    end

    # TODO: Replace with proper permissions
    def can?(perform_command, target)
      true
    end

    def orphaned?
      contacts.empty?
    end

    # A specialist User that has permission to do everything.
    # WARNING: Use sparingly as this user bypasses all the normal checks in the system.
    # Use StandardProcedure::User.root to set up your accounts before you've added any administrators
    # or to make it easier to write tests
    def self.root
      @root ||=
        StandardProcedure::User::Root.where(reference: "root").first_or_create(
          name: "Root"
        )
    end
  end
end
