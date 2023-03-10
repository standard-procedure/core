module StandardProcedure
  class Contact < ApplicationRecord
    has_fields
    has_reference
    belongs_to :user, class_name: "StandardProcedure::User", optional: true
    belongs_to :group, class_name: "StandardProcedure::Group"
    belongs_to :role, class_name: "StandardProcedure::Role"
    has_many :items,
             -> { order :name },
             class_name: "StandardProcedure::WorkflowItem",
             foreign_key: "contact_id",
             dependent: :destroy
    has_many :assigned_items,
             -> { order :name },
             class_name: "StandardProcedure::WorkflowItem",
             foreign_key: "assigned_to_id",
             dependent: :destroy
    has_many :notifications,
             -> { order :acknowledged_at },
             class_name: "StandardProcedure::Notification",
             dependent: :destroy
    has_and_belongs_to_many :alerts, class_name: "StandardProcedure::Alert"
    has_many :sent_messages,
             class_name: "StandardProcedure::Message",
             foreign_key: "sender_id"
    has_many :received_messages,
             class_name: "StandardProcedure::MessageRecipient",
             foreign_key: "recipient_id"
    has_many :messages, through: :received_messages
    delegate :account, to: :role
    delegate :access_level, to: :role

    before_validation :generate_access_code
    validates :access_code,
              presence: true,
              uniqueness: {
                case_sensitive: false,
              },
              if: :detached?

    def detached?
      user.blank?
    end

    command :send_message do |user, recipients: [], subject: "", contents: ""|
      Message
        .create!(sender: self, subject: subject, contents: contents)
        .tap do |message|
          recipients.each do |recipient|
            message.message_recipients.create! recipient: recipient
            recipient
              .notifications
              .create!(
                details: contents,
                type: "StandardProcedure::Notification::MessageReceived",
              )
              .tap { |notification| notification.link_to message }
          end
        end
    end

    protected

    def generate_access_code
      if user.blank?
        self.access_code =
          "#{4.random_letters}-#{4.random_letters}".upcase if access_code.blank?
      else
        self.access_code = ""
      end
    end
  end
end
