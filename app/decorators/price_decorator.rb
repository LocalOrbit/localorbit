class PriceDecorator < Draper::Decorator
  include ActiveSupport::NumberHelper
  delegate_all

  def organization_name
    organization.try(:name) || "All Buyers"
  end

  def market_name
    market.try(:name) || "All Markets"
  end

  def quick_info
    str = formatted_price
    str += " %d+" % min_quantity if min_quantity > 1
    str
  end

  def formatted_price
    number_to_currency sale_price
  end

  def formatted_units
    min_quantity > 1 ? " %d+ #{product.unit_plural}" % min_quantity : "per #{product.unit_singular}"
  end

  def category_checked(pcts)
    if market.nil?
      mkt_id = "all"
    else
      mkt_id = market.id
    end
    !pcts.nil? && !pcts[mkt_id.to_s].nil? && pcts[mkt_id.to_s] > 0 ? "checked" : ""
  end
end
