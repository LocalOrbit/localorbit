require "capybara/rspec"
require "capybara/rails"
require "capybara/poltergeist"
require "selenium-webdriver"

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
                                    timeout: 60,
                                    inspector: true,
                                    phantomjs_options: ['--ssl-protocol=tlsv1'])
end

Capybara.javascript_driver = :poltergeist

#Capybara.register_driver :selenium do |app|
#  Capybara::Selenium::Driver.new(app)
#end

#Capybara.javascript_driver = :selenium

Capybara.default_max_wait_time = (ENV["CAPYBARA_WAIT_TIME"] || 20).to_i

# hidden elements are ignored by default
# Capybara.ignore_hidden_elements = true

RSpec.configure do |config|
  config.before(:each, js: true) do
    # page.driver.browser.url_blacklist = ['intercom.io']
  end
end
