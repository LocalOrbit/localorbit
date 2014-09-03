# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

if ENV["DOMAIN"]
  # Dont' take my word for it: http://rubular.com/r/YtzRyVnuDB
  regexp = /^(?!.*#{Regexp.escape(ENV["DOMAIN"])}$).*$/
  use Rack::CanonicalHost, ENV["DOMAIN"], if: regexp
end

run Rails.application
