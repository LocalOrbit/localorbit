class ProductDecorator < Draper::Decorator
  delegate_all

  def has_custom_seller_info?
    self[:location_id].present? || self[:who_story].present? || self[:how_story].present?
  end

  def location_options_for_select
    # NOTE: Location options for new products are loaded on demand
    return [] unless organization

    organization.locations.visible.alphabetical_by_name.map do |location|
      [location.name, location.id]
    end
  end

  def who_story
    self[:who_story].presence || (organization ? organization.who_story : nil)
  end

  def how_story
    self[:how_story].presence || (organization ? organization.how_story : nil)
  end

  def initial_price
    prices.decorate.first
  end

  def location
    Location.visible.find_by(id: location_id) || organization.shipping_location
  end

  def location_map
    if location
      location_string = [location.address, location.city, location.state].join(',').gsub(' ', '+')
      "http://maps.googleapis.com/maps/api/staticmap?center=#{location_string}&zoom=14&size=300x200&sensor=false&key=#{Figaro.env.google_maps_key}"
    else
      ""
    end
  end

  def cart_quantity
    return unless context[:current_cart]

    if p = context[:current_cart].items.find_by(product_id: id)
      p.quantity
    else
      nil
    end
  end
end
