class ProductDecorator < Draper::Decorator
  delegate_all

  def has_custom_seller_info?
    self[:location_id].present? || self[:who_story].present? || self[:how_story].present?
  end

  def location_options_for_select
    # NOTE: Location options for new products are loaded on demand
    return [] unless organization

    organization.locations.alphabetical_by_name.map do |location|
      [location.name, location.id]
    end
  end

  def who_story
    self[:who_story].presence || organization.who_story
  end

  def how_story
    self[:how_story].presence || organization.how_story
  end

  def location
    location_id ? Location.find(location_id) : organization.locations.default_billing
  end
end
