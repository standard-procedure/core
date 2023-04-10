class ApplicationRecord < StandardProcedure::ApplicationRecord
  primary_abstract_class
  include StandardProcedure::HasIcon
  include StandardProcedure::HasName
  include StandardProcedure::HasDescription
  include StandardProcedure::HasLogo
  include StandardProcedure::HasReference
  include StandardProcedure::HasFieldDefinitions
  include StandardProcedure::HasFields
  include StandardProcedure::HasLinkedItems
  is_linked_to :commands, class_name: "StandardProcedure::Command"
  is_linked_to :attached_messages, class_name: "StandardProcedure::Message"
  is_linked_to :linked_notifications, class_name: "StandardProcedure::Notification"

  include StandardProcedure::HasCommands
  defines_commands

  include StandardProcedure::HasWorkflow
  include StandardProcedure::HasMessages
  include StandardProcedure::HasNotifications
end
