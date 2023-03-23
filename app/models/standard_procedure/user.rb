module StandardProcedure
  class User < ApplicationRecord
    is_user
    has_reference copy_to: :name
    has_name
    has_many :contacts, class_name: "StandardProcedure::Contact", dependent: :nullify

    command :attach do |access_code:, performed_by:|
      Contact.find_by(access_code: access_code).tap do |contact|
        raise InvalidAccessCode.new(access_code) if contact.nil?
        contact.update user: self
      end
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

    def detached?
      contacts.empty?
    end

    # A specialist User that has permission to do everything.
    # WARNING: Use sparingly as this user bypasses all the normal checks in the system.
    # Use StandardProcedure::User.root to set up your accounts before you've added any administrators
    # or to make it easier to write tests
    def self.root
      @root ||= StandardProcedure::User::Root.where(reference: "root").first_or_create(name: "Root")
    end

    class InvalidAccessCode < StandardError
    end
  end
end
