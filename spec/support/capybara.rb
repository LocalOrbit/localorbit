require "capybara/rspec"
require "capybara/rails"
require "capybara/poltergeist"

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
                                    timeout: 60.seconds,
                                    inspector: true,
                                    phantomjs_options: ['--ssl-protocol=tlsv1'])
end

Capybara.javascript_driver = :poltergeist
Capybara.default_max_wait_time = (ENV["CAPYBARA_WAIT_TIME"] || 10).to_i

# hidden elements are ignored by default
# Capybara.ignore_hidden_elements = true

RSpec.configure do |config|
  config.before(:each, js: true) do
    # page.driver.browser.url_blacklist = ['intercom.io']
  end
end
