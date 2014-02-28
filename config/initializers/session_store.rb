# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store,
  key: '_local_orbit_session',
  domain: Rails.env.test? ? :all : ".#{Figaro.env.domain}"
