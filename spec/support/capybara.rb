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

#RSpec.configure do |config|
#  config.before(:each, js: true) do
    # page.driver.browser.url_blacklist = ['intercom.io']
#  end
#end

# monkey patch to find green tests the can be sped up
#   from: https://www.simplybusiness.co.uk/about-us/tech/2015/02/flaky-tests-and-capybara-best-practices/
# module Capybara
#   module Node
#     class Base
#       def synchronize(seconds=Capybara.default_wait_time, options = {})
#         start_time = Time.now

#         if session.synchronized
#           yield
#         else
#           session.synchronized = true
#           begin
#             yield
#           rescue => e
#             session.raise_server_error!
#             raise e unless driver.wait?
#             raise e unless catch_error?(e, options[:errors])
#             if (Time.now - start_time) >= seconds
#               warn "Capybara's timeout limit reached - if your tests are green, something is wrong"
#               raise e
#             end
#             sleep(0.05)
#             raise Capybara::FrozenInTime, "time appears to be frozen, Capybara does not work with libraries which freeze time, consider using time travelling instead" if Time.now == start_time
#             reload if Capybara.automatic_reload
#             retry
#           ensure
#             session.synchronized = false
#           end
#         end
#       end
#     end
#   end
# end
