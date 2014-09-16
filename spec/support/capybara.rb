require "capybara/rspec"
require "capybara/rails"
require "capybara/poltergeist"

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, inspector: true)
end

Capybara.javascript_driver = :poltergeist
Capybara.default_wait_time = (ENV["CAPYBARA_WAIT_TIME"] || 30).to_i
