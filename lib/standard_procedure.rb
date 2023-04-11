require "standard_procedure/version"
require "standard_procedure/engine"
require_relative "./extensions/date"
require_relative "./extensions/datetime"
require "rujitsu"

module StandardProcedure
  extend ActiveSupport::Concern

  included do
    path = File.join(File.dirname(__FILE__), "standard_procedure", "has_*.rb")
    Dir[path].each do |file|
      puts file
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

    include StandardProcedure::HasWorkflow
    include StandardProcedure::HasMessages
    include StandardProcedure::HasNotifications
  end

  class Exception < StandardError
  end

  def self.config
    @config ||= ActiveSupport::OrderedOptions.new
  end
end
