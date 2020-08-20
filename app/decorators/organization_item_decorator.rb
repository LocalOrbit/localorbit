class OrganizationItemDecorator < Draper::Decorator
  include MapHelper

  def has_custom_seller_info?
    self[:location_id].present? || self[:who_story].present? || self[:how_story].present?
  end

  def location_options_for_select
    # NOTE: Location options for new products are loaded on demand
    return [] unless organization

    organization.locations.visible.order("locations.default_shipping DESC").alphabetical_by_name.map do |location|
      [location.name, location.id]
    end
  end

  def who_story
    self[:who_story].presence || (organization ? organization.who_story : nil)
  end

  def how_story
    self[:how_story].presence || (organization ? organization.how_story : nil)
  end

  def location
    return @location if defined?(@location)
    @location = (location_id && Location.visible.find_by(id: location_id)) || organization.shipping_location
  end

  def location_map(w=300, h=200)
    # if location && location.geocode
    #   google_static_map([location.geocode], location.geocode, w, h, 11)
    # else
    #   ""
    # end
    ""
  end

  def location_label
    "#{location.city}, #{location.state}" if location
  end

  def location_address
    "<p class='adr'><span class='street-address'>#{location.address}</span> <span class='locality'>#{location.city}</span>, <span class='region'>#{location.state}</span></p>".html_safe if location
  end
end
