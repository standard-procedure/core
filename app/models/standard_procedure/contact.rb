module StandardProcedure
  class Contact < Folder
    belongs_to :user, class_name: "StandardProcedure::User", optional: true
    belongs_to :role, class_name: "StandardProcedure::Role"
    has_many :assigned_documents,
             -> { order :name },
             class_name: "StandardProcedure::Document",
             foreign_key: "assigned_to_id",
             dependent: :destroy
    has_many :notifications,
             -> { order :acknowledged_at },
             foreign_key: "contact_id",
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
    validate :parent_must_be_an_organisation
    validates :access_code,
              presence: true,
              uniqueness: {
                case_sensitive: false,
              },
              if: :detached?

    def organisation
      parent
    end

    def detached?
      user.blank?
    end

    command :send_message do |recipients: [], subject:, contents:, performed_by:|
      message =
        Message.create!(sender: self, subject: subject, contents: contents)
      recipients.each do |recipient|
        message.message_recipients.create! recipient: recipient
        notification =
          recipient.notifications.create!(
            details: contents,
            type: "StandardProcedure::Notification::MessageReceived",
          )
        notification.link_to message
      end
      message
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

    def parent_must_be_an_organisation
      if !parent.is_a? StandardProcedure::Organisation
        errors.add :parent, :must_be_an_organisation
      end
    end
  end
end
