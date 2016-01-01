require "capybara/rspec"
require "capybara/rails"
require "capybara/poltergeist"
require "capybara-webkit"

Capybara.register_driver :webkit do |app|
  Capybara::Webkit::Driver.new(app)
end

Capybara.javascript_driver = :webkit
Capybara.default_max_wait_time = (ENV["CAPYBARA_WAIT_TIME"] || 20).to_i

# hidden elements are ignored by default
# Capybara.ignore_hidden_elements = true

#RSpec.configure do |config|
#  config.before(:each, js: true) do
    # page.driver.browser.url_blacklist = ['intercom.io']
#  end
#end
