require 'capybara/rails'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'webdrivers'
require 'webdrivers/chromedriver'

Capybara.default_max_wait_time = (ENV['CAPYBARA_WAIT_TIME'] || 180).to_i

# hidden elements are ignored by default
# Capybara.ignore_hidden_elements = true

client = Selenium::WebDriver::Remote::Http::Default.new
client.read_timeout = 120 # instead of default 60, in seconds

Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, http_client: client)
end

Capybara.register_driver :selenium_chrome_headless do |app|
  opts = Selenium::WebDriver::Chrome::Options.new
  opts.add_argument('--headless')
  opts.add_argument('--no-sandbox')
  opts.add_argument('--disable-gpu')
  opts.add_argument('--window-size=1400,2000')
  Capybara::Selenium::Driver.new(app, browser: :chrome, http_client: client, options: opts)
end

Capybara.default_driver = :selenium_chrome_headless
Capybara.javascript_driver = :selenium_chrome_headless

# For debugging feature specs
# Capybara.default_driver = :selenium_chrome
# Capybara.javascript_driver = :selenium_chrome