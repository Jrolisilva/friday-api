require_relative "boot"

require "rails"
# require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"  # desativado
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
# require "action_view/railtie"
# require "action_cable/engine"
# require "rails/test_unit/railtie"
# require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module FridayApi
  class Application < Rails::Application
    config.load_defaults 7.2
    # config.autoload_lib(ignore: %w[assets tasks])
    config.api_only = true
  end
end
