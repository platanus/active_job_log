module ActiveJobLog
  class Engine < ::Rails::Engine
    isolate_namespace ActiveJobLog

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end

    initializer "initialize" do
      require_relative "./log_ext"
    end
  end
end
