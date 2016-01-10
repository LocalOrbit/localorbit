require "capybara/rspec"
require "capybara/rails"
require "capybara/poltergeist"

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
                                    timeout: 120,
                                    inspector: false,
                                    debug: false,
                                    js_errors: false,
                                    phantomjs_options: ['--debug=false', '--ssl-protocol=TLSv1'])
end

Capybara.javascript_driver = :poltergeist

#Capybara.register_driver :chrome do |app|
#  Capybara::Selenium::Driver.new(app, :browser => :chrome)
#end

#Capybara.javascript_driver = :chrome

#Capybara::Webkit.configure do |config|
#  config.allow_unknown_urls
#end

#Capybara.javascript_driver = :webkit


#Capybara.register_driver :selenium do |app|
#  Capybara::Selenium::Driver.new(app)
#end

#Capybara.javascript_driver = :selenium

Capybara.default_max_wait_time = (ENV["CAPYBARA_WAIT_TIME"] || 180).to_i

# hidden elements are ignored by default
# Capybara.ignore_hidden_elements = true

#RSpec.configure do |config|
#  config.before(:each, js: true) do
    # page.driver.browser.url_blacklist = ['intercom.io']
#  end
#end
