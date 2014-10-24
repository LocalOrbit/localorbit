# Be sure to restart your server when you modify this file.

session_suffix = Figaro.env.deploy_env == 'production' ? '' : "_#{Figaro.env.deploy_env}"
session_key = "_LocalOrbit_session_data#{session_suffix}"

# Use .(domain) unless testing:
domain = Rails.env.test? ? nil : ".#{Figaro.env.domain}"

LocalOrbit::Application.config.session_store(:cookie_store, key: session_key, domain: domain)
