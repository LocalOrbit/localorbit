class MarketMapSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :name, :latitude, :longitude, :plan_name, :market_path

  def latitude
    object.addresses.visible.first.geocode.latitude
  end

  def longitude
    object.addresses.visible.first.geocode.longitude
  end

  def plan_name
    object.organization.plan.try(:name)
  end

  def market_path
    admin_market_path(object)
  end
end
