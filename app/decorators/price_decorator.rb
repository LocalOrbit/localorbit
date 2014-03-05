class PriceDecorator < Draper::Decorator
  delegate_all

  def organization_name
    organization.try(:name) || "All Buyers"
  end

  def market_name
    market.try(:name) || "All Markets"
  end

  def quick_info
    str = "$%.2f" % sale_price
    if min_quantity > 1
      str += " %d+" % min_quantity
      str += " #{product.unit_plural}"
    end
    str
  end
end
