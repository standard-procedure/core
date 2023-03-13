require "ancestry"
module StandardProcedure
  class Engine < ::Rails::Engine
    isolate_namespace StandardProcedure
    config.generators { |g| g.test_framework :rspec }
    Ancestry.default_ancestry_format = :materialized_path2
  end
end
