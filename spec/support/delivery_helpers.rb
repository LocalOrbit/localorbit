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


  def see_product_delivery_choices(*dels)
    dels.each do |info|
      see_product_delivery_choice(info)
    end
  end

  def see_product_delivery_choice(info)
    dsd = info[:delivery_schedule].decorate
    dayname = dsd.buyer_weekday.pluralize
    obj = Dom::Admin::ProductDelivery.find_by_weekday( dayname )
    # See it's checked properly:
    if info[:checked]
      expect(obj).to be_checked, "Expected #{dayname} to be checked"
    else
      expect(obj).not_to be_checked, "Expected #{dayname} NOT to be checked"
    end

    # See theb description is rendered proplery
    expect_str = dsd.product_schedule_description(html:false)
    if info[:required]
      expect_str += " (required)"
    end
    expect(obj.description).to eq(expect_str), "Expected #{dayname} to have description '#{expect_str}' but was '#{obj.description}'"
  end

  # def check_product_delivery_choice(days:nil,delivery_schedule:nil)
  #   if days
  #     Dom::Admin::ProductDelivery.find_by_weekday(days).check!
  #   elsif delivery_schedule 
  #     Dom::Admin::ProductDelivery.find_by_weekday(delivery_schedule.decorate.buyer_weekday.pluralize).check!
  #
  #   end
  # end
  # def uncheck_product_delivery_choice(days:nil,delivery_schedule:nil)
  #   if days
  #     Dom::Admin::ProductDelivery.find_by_weekday(days).uncheck!
  #   elsif delivery_schedule 
  #     Dom::Admin::ProductDelivery.find_by_weekday(delivery_schedule.decorate.buyer_weekday.pluralize).check!
  #
  #   end
  # end
end

RSpec.configure do |config|
  config.include DeliveryHelpers
end
