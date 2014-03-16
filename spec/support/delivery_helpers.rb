module DeliveryHelpers
  def choose_delivery(schedule_id=nil)
    unless schedule_id
      expect(page).to have_css("#deliveries") #waits for special cases
      schedule = Dom::Buying::DeliveryChoice.first
      raise "No delivery schedules in view" if schedule.nil?
      schedule.choose!
    end
  end
end

RSpec.configure do |config|
  config.include DeliveryHelpers
end
