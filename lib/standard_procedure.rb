require "standard_procedure/version"
require "standard_procedure/engine"
require_relative "./extensions/date"
require_relative "./extensions/datetime"
require_relative "../app/standard_procedure"
require "rujitsu"

module StandardProcedure
  class Exception < StandardError
  end

  def StandardProcedure.config
    @config ||= ActiveSupport::OrderedOptions.new
  end
end
