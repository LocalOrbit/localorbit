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
end
