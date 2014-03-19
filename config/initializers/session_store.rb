# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store,
  key: (Rails.env.production? ? "_local_orbit_session" : "_local_orbit_session_#{Rails.env}"),
  domain: (Rails.env.test? || Figaro.env.domain == 'localhost') ? :all : ".#{Figaro.env.domain}"
