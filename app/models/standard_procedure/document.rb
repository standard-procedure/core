module StandardProcedure
  class Document < FolderItem
    belongs_to :template, class_name: "StandardProcedure::DocumentTemplate", foreign_key: "template_id"
    belongs_to :status, class_name: "StandardProcedure::WorkflowStatus", foreign_key: "status_id", optional: true
    belongs_to :assigned_to, class_name: "StandardProcedure::Contact", optional: true
    has_many :actions, class_name: "StandardProcedure::WorkflowAction", dependent: :destroy
    has_many :alerts, -> { order :due_at }, class_name: "StandardProcedure::Alert", as: :item, dependent: :destroy
    delegate :workflow, to: :status
    delegate :available_actions, to: :status
    delegate :name_for, to: :status
    delegate :required_fields_for, to: :status
    has_and_belongs_to_many :folder_items,
      class_name: "StandardProcedure::FolderItem",
      join_table: "standard_procedure_related_items",
      foreign_key: "document_id",
      association_foreign_key: "folder_item_id"
    enum item_status: {active: 0, completed: 100, cancelled: -1}

    command :add_alert

    # `assign_to @user, contact: @contact`
    # - user: the user who is performing the action
    # - contact: the contact to whom the item will be assigned
    command :assign_to do |contact:, performed_by:|
      update! assigned_to: contact
      contact.notifications.create!.tap do |notification|
        notification.link_to self
      end
    end

    # `perform_action user, action_reference: @action_reference, **params`
    # - performed_by: the user who is performing the action
    # - action_reference: the reference of the action to perform
    # - **params: any other parameters needed by the action
    command :perform_action do |action: nil, performed_by: nil, **params|
      status.perform_action action: action, performed_by: performed_by, **params.merge(document: self)
    end

    # `set_status user, reference: "a_status_reference"`
    # or
    # `set_status user, status: @status`
    command :set_status do |status: nil, reference: nil, performed_by: nil|
      status ||= workflow.status(reference)
      update! status: status
      status.document_added document: self, performed_by: performed_by
    end

    def find_contact_from(reference)
      return reference if reference.is_a? StandardProcedure::Contact
      return nil unless reference.is_a? String
      if !respond_to? reference.to_sym
        return account.contacts.find_by(reference: reference)
      end
      possible_contact = send reference.to_sym
      if possible_contact.is_a?(StandardProcedure::Contact)
        possible_contact
      end
    end
  end
end
