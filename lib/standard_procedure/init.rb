ActiveSupport.on_load(:active_record) do
  Dir[File.join("..", "..", "app", "models", "concerns", "standard_procedure", "*.rb")].each do |file|
    require_relative file
  end

  include StandardProcedure::HasIcon
  include StandardProcedure::HasName
  include StandardProcedure::HasDescription
  include StandardProcedure::HasLogo
  include StandardProcedure::HasReference
  include StandardProcedure::HasFieldDefinitions
  include StandardProcedure::HasFields
  include StandardProcedure::HasLinkedItems
  include StandardProcedure::HasCommands

  defines_commands
  is_linked_to :commands
  is_linked_to :notifications
end
