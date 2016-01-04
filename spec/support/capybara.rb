require "capybara/rspec"
require "capybara/rails"
require "capybara/poltergeist"

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
                                    timeout: 180,
                                    inspector: true,
                                    debug: false,
                                    js_errors: false,
                                    phantomjs_options: ['--debug=false', '--ssl-protocol=any'])
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
