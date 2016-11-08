class LotDecorator < Draper::Decorator
  delegate_all

  def organization_name
    organization.try(:name) || "All Buyers"
  end

  def market_name
    market.try(:name) || "All Markets"
  end
end
