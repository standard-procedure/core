require "ancestry"
module StandardProcedure
  class Engine < ::Rails::Engine
    isolate_namespace StandardProcedure
    config.generators { |g| g.test_framework :rspec }
  end
end
