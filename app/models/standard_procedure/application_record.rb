require "acts_as_list"

module StandardProcedure
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
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
    is_linked_to :commands, class_name: "StandardProcedure::Command"
    is_linked_to :notifications, class_name: "StandardProcedure::Notification"
  end
end
