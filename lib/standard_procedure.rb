require "standard_procedure/version"
require "standard_procedure/engine"
require_relative "../app/standard_procedure.rb"
require "rujitsu"

module StandardProcedure
  class Exception < StandardError
  end

  def StandardProcedure.config
    @config ||= ActiveSupport::OrderedOptions.new
  end
end
