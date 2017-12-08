require 'rollbar'

Rollbar.configure do |config|
  config.access_token = '57707544d96f4bffb09f5a3ea60fae81'
  unless Rails.env.production?
    config.enabled = false
  end

  config.exception_level_filters.merge!('Encoding::UndefinedConversionError' => 'ignore')
  config.exception_level_filters.merge!('ActionController::InvalidAuthenticityToken' => 'ignore')

end
