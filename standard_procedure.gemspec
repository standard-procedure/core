require_relative "lib/standard_procedure/version"

Gem::Specification.new do |spec|
  spec.name = "standard_procedure"
  spec.version = StandardProcedure::VERSION
  spec.authors = ["Rahoul Baruah"]
  spec.email = ["rahoulb@standardprocedure.app"]
  spec.homepage = "https://standardprocedure.app"
  spec.summary = "Standard Procedure Core utilities"
  spec.description = "Standard Procedure Core utilities"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://example.com"
  spec.metadata["changelog_uri"] = "https://example.com"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]
  end
  spec.test_files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["spec/**/*"]
  end

  spec.add_dependency "rails", ">=  6.1"
  spec.add_dependency "acts_as_list", ">= 1.0"
  spec.add_dependency "rujitsu"
end
