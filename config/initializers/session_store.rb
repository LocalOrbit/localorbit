# Be sure to restart your server when you modify this file.

session_environment = Rails.env.production? ? '' : "_#{Rails.env}"

session_suffix = ENV.fetch('LOCALORBIT_INTERNAL', 'NO') == 'YES' ? '_INTERNAL' : ''

session_key = "_LocalOrbit_session_data#{session_environment}#{session_suffix}"

# Use .(domain) unless testing:
domain = Rails.env.test? ? nil : ".#{ENV.fetch('DOMAIN')}"

LocalOrbit::Application.config.session_store(:cookie_store, key: session_key, domain: domain)
