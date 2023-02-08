class ApplicationRecord < StandardProcedure::ApplicationRecord
  primary_abstract_class
  defines_commands
end
