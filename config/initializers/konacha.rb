if defined?(Konacha)
  require "capybara/poltergeist"
  Konacha.configure do |config|
    config.driver = :poltergeist
  end
  WebMock.allow_net_connect!
end

