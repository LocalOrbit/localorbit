require File.expand_path('../boot', __FILE__)

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LocalOrbit
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    config.autoload_paths += %W(#{config.root}/lib #{config.root}/lib/constraints)

    config.assets.precompile += %w(chosen-sprite.png chosen-sprite@2x.png)

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    Figaro.load
    config.action_mailer.asset_host = Figaro.env.asset_host
    config.action_mailer.default_url_options = {host: Figaro.env.domain}

    config.to_prepare do
      Devise::Mailer.layout "email"
      DeviseController.skip_before_action :ensure_market_affiliation
    end

    config.middleware.use Rack::Cors do
      allow do
        origins Figaro.env.domain, "*.#{Figaro.env.domain}"
        resource '/assets/*', headers: :any, methods: :get
      end
    end
  end
end
