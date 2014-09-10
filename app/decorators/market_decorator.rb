class MarketDecorator < Draper::Decorator
  include ActionView::Helpers::NumberHelper
  include Draper::LazyHelpers
  include MapHelper
  include Decorators::BankAccounts

  delegate_all

  def affiliation_item(_)
    content_tag(:li, "#{name}, Market Manager")
  end

  def first_address
    addresses.visible.first
  end

  def seller_locations_map(w=400, h=400)
    addresses = organizations.selling.map do |seller|
      seller.shipping_location.geocode if seller.shipping_location
    end.compact

    if (center = first_address.try(:geocode))
      static_map(addresses, center, w, h)
    else
      ""
    end
  end

  def has_address?
    addresses.visible.any?
  end

  def street_address
    first_address.address
  end

  def city_state_zip
    "#{first_address.city}, #{first_address.state} #{first_address.zip} "
  end

  def phone_number
    first_address.phone
  end

  def display_contact_phone
    number = contact_phone.to_s.gsub(/[^0-9]/, "")

    # if we have a clean phone number, format it appropriately, otherwise
    # just display what they give us
    if number.length == 10
      number_to_phone(number, area_code: true)
    else
      contact_phone.to_s
    end
  end

  def display_plan_interval
    if plan_interval == 1
      "Monthly"
    elsif plan_interval == 12
      "Yearly"
    else
      "Not Set"
    end
  end

  def header
    if name.blank?
      changes[:name].first
    else
      name
    end
  end

end
