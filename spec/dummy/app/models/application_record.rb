class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  include StandardProcedure::HasName
  include StandardProcedure::HasDescription
  include StandardProcedure::HasLogo
  include StandardProcedure::HasReference
  include StandardProcedure::HasFields
  include StandardProcedure::HasLinkedItems
  include StandardProcedure::HasAncestors
  include StandardProcedure::HasCommands
  include StandardProcedure::HasFieldDefinitions
  include StandardProcedure::HasFieldValues
end
