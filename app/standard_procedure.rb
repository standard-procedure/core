Dir[File.join(File.dirname(__FILE__), "models", "concerns", "**/*.rb")] do |file|
  require_relative file
end
Dir[File.join(File.dirname(__FILE__), "models", "**/*.rb")] do |file|
  require_relative file
end
