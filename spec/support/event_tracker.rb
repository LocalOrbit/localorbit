RSpec.configure do |config|
  config.before(:each) do
    EventTracker.capture_events = true
    EventTracker.previously_captured_events.clear
  end

  config.after(:each) do
    EventTracker.capture_events = false
    EventTracker.previously_captured_events.clear
  end
end
