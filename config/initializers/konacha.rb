if defined?(Konacha)
  Konacha.configure do |konacha|
    konacha.driver    = :selenium_chrome_headless
  end
  WebMock.allow_net_connect!
end

