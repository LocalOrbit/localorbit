require 'capybara/rails'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'

Capybara.default_max_wait_time = (ENV['CAPYBARA_WAIT_TIME'] || 180).to_i

# hidden elements are ignored by default
# Capybara.ignore_hidden_elements = true

Capybara.javascript_driver = :selenium_chrome_headless

#RSpec.configure do |config|
#  config.before(:each, js: true) do
    # page.driver.browser.url_blacklist = ['intercom.io']
#  end
#end
