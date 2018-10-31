require 'capybara/rails'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'

Capybara.default_max_wait_time = (ENV['CAPYBARA_WAIT_TIME'] || 180).to_i

# hidden elements are ignored by default
# Capybara.ignore_hidden_elements = true

client = Selenium::WebDriver::Remote::Http::Default.new
client.read_timeout = 120 # instead of default 60, in seconds

browser_options = Selenium::WebDriver::Chrome::Options.new()
browser_options.args << '--headless'
browser_options.args << '--disable-gpu'

Capybara.register_driver :selenium_chrome_headless do |app|
  Capybara::Selenium::Driver.new(app,
                                 http_client: client,
                                 browser: :chrome,
                                 options: browser_options)
end

Capybara.javascript_driver = :selenium_chrome_headless
Chromedriver.set_version '2.37'
