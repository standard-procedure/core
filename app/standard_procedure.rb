Dir[File.join(File.dirname(__FILE__), "models", "**/*.rb")] do |file|
  puts file
  require_relative file
end
