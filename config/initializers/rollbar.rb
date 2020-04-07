require 'rollbar'

Rollbar.configure do |config|
  config.access_token = '57707544d96f4bffb09f5a3ea60fae81'
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
