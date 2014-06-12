class MarketDecorator < Draper::Decorator
  include ActionView::Helpers::NumberHelper
  include Draper::LazyHelpers
  include MapHelper

  delegate_all

  def first_address
    addresses.first
  end

  def seller_locations_map(w=400, h=400)
    addresses = organizations.selling.map do |seller|
      seller.shipping_location.geocode if seller.shipping_location
    end.compact

    if center = first_address.try(:geocode)
      static_map(addresses, center, w, h)
    else
      ""
    end
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
    number_to_phone(contact_phone.to_s.gsub(/[^0-9]/, ""), area_code: true)
  end

  def header
    if name.blank?
      changes[:name].first
    else
      name
    end
  end

  def plan_options
    Plan.all.map {|plan| [plan.name, plan.id] }
  end
end
