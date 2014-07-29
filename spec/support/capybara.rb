require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, inspector: true)
end

Capybara.javascript_driver = :poltergeist
Capybara.default_wait_time = (ENV['CAPYBARA_WAIT_TIME'] || 10).to_i

Capybara.register_driver :ff_csv do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile["browser.download.dir"] = DownloadHelpers::PATH.to_s
  profile["browser.download.folderList"] = 2
  profile["browser.helperApps.neverAsk.saveToDisk"] = "text/csv"
  profile["plugin.disable_full_page_plugin_for_types"] = "text/csv"

  Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile)
end
