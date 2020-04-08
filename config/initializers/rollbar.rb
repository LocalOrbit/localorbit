require 'rollbar'

Rollbar.configure do |config|
  config.access_token = ENV.fetch('ROLLBAR_ACCESS_TOKEN')
  config.enabled = Rails.env.production? || Rails.env.staging? || ENV.fetch('USE_ROLLBAR') == 'true'

  config.exception_level_filters.merge!(
    'ActionController::InvalidAuthenticityToken' => 'ignore',
    'ActionController::RoutingError'             => 'ignore',
    'ActiveRecord::RecordNotFound'               => 'info',
    'ActiveRecord::RecordNotUnique'              => 'info',
    'Dragonfly::Shell::CommandFailed'            => 'info',
    'Encoding::UndefinedConversionError'         => 'ignore'
  )
end
