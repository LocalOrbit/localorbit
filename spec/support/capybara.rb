require "capybara/rspec"
require "capybara/rails"
require "capybara/poltergeist"
require 'capybara-screenshot/rspec'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
                                    timeout: 120,
                                    inspector: false,
                                    debug: false,
                                    js_errors: false,
                                    phantomjs_options: ['--debug=false', '--ssl-protocol=TLSv1.2'])
end

Capybara.javascript_driver = :poltergeist

#Selenium::WebDriver::Firefox::Binary.path='/Applications/FirefoxDeveloperEdition.app/Contents/MacOS/firefox-bin'
#Capybara.javascript_driver = :selenium

Capybara.default_max_wait_time = (ENV["CAPYBARA_WAIT_TIME"] || 180).to_i

# hidden elements are ignored by default
# Capybara.ignore_hidden_elements = true

#RSpec.configure do |config|
#  config.before(:each, js: true) do
    # page.driver.browser.url_blacklist = ['intercom.io']
#  end
#end
