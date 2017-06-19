require 'rollbar'

Rollbar.configure do |config|
  config.access_token = 'd9b4e2c39e564c18948da47387482174'
  unless Rails.env.production?
    config.enabled = false
  end

  config.exception_level_filters.merge!('Encoding::UndefinedConversionError' => 'ignore')
  config.exception_level_filters.merge!('ActionController::InvalidAuthenticityToken' => 'ignore')

end
