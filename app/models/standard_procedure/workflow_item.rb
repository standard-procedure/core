module StandardProcedure
  class WorkflowItem < ApplicationRecord
    has_name
    has_reference
    has_fields
    belongs_to :template, class_name: "StandardProcedure::WorkflowItemTemplate"
    belongs_to :status, class_name: "StandardProcedure::WorkflowStatus"
    belongs_to :group, class_name: "StandardProcedure::Group"
    belongs_to :contact,
               class_name: "StandardProcedure::Contact",
               optional: true
    belongs_to :assigned_to,
               class_name: "StandardProcedure::Contact",
               optional: true
    has_many :actions,
             class_name: "StandardProcedure::WorkflowAction",
             dependent: :destroy
    has_many :alerts,
             -> { order :due_at },
             class_name: "StandardProcedure::Alert",
             as: :item,
             dependent: :destroy
    delegate :workflow, to: :status
    delegate :account, to: :workflow
    delegate :available_actions, to: :status
    delegate :name_for, to: :status
    delegate :required_fields_for, to: :status
    has_and_belongs_to_many :folder_items,
                            class_name: "StandardProcedure::FolderItem",
                            join_table: "standard_procedure_related_items",
                            foreign_key: "workflow_item_id",
                            association_foreign_key: "folder_item_id"
    enum item_status: { active: 0, completed: 100, cancelled: -1 }
    acts_as_list scope: :status

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
    # - user: the user who is performing the action
    # - action_reference: the reference of the action to perform
    # - **params: any other parameters needed by the action
    command :perform_action do |**params|
      user = params.delete(:performed_by)
      status.perform_action user, **params.merge(item: self)
    end

    # `set_status user, reference: "a_status_reference"`
    # or
    # `set_status user, status: @status`
    command :set_status do |status: nil, reference: nil, performed_by:|
      status ||= workflow.status(reference)
      update! status: status
      status.item_added item: self, performed_by: performed_by
    end

    def find_contact_from(reference)
      return reference if reference.is_a? StandardProcedure::Contact
      return nil unless reference.is_a? String
      unless self.respond_to? reference.to_sym
        return account.contacts.find_by(reference: reference)
      end
      possible_contact = self.send reference.to_sym
      return(
        (
          if possible_contact.is_a?(StandardProcedure::Contact)
            possible_contact
          else
            nil
          end
        )
      )
    end
  end
end
