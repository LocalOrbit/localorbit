class Price < ActiveRecord::Base
  belongs_to :product
  belongs_to :market
  belongs_to :organization

  scope :view_sorted, lambda {
    joins("LEFT JOIN markets ON prices.market_id = markets.id LEFT JOIN organizations ON prices.organization_id = organizations.id").
    order('markets.name NULLS FIRST, organizations.name NULLS FIRST, min_quantity')
  }

  validates :min_quantity, :sale_price, numericality: { greater_than: 0 }
  validates :min_quantity, uniqueness: { scope: [:product_id, :market_id, :organization_id] }

  def net_price
    ((sale_price || 0) * net_percent).round(2)
  end

  # TODO: Implement with real per market fee structure
  def net_percent
    BigDecimal.new("0.97")
  end
end
