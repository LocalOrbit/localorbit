if defined?(Konacha)
  Capybara.register_driver :slow_poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, :timeout => 2.minutes)
  end
  Konacha.configure do |konacha|
    require 'capybara/poltergeist'
    konacha.driver    = :slow_poltergeist
  end
  WebMock.allow_net_connect!
end

