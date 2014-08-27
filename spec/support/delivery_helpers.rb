module DeliveryHelpers
  def choose_delivery(description=nil)
    expect(page).to have_css("#deliveries") # waits for special cases

    if description.present?
      choices = Dom::Buying::DeliveryChoice.all
      schedule = choices.select do |choice|
        choice.node.text.match Regexp.new(description)
      end.first
    else
      schedule = Dom::Buying::DeliveryChoice.first
    end

    if schedule.nil?
      if description.present?
        raise "Could not find schedule with description: #{description} \n\nAvailable Deliveries: #{available_deliveries}"
      else
        raise "No deliveries exist in current view"
      end
    end

    schedule.choose!
  end

  def available_deliveries
    choices = Dom::Buying::DeliveryChoice.all

    choices.map do |dc|
      dc.node.text
    end
  end
end

RSpec.configure do |config|
  config.include DeliveryHelpers
end
