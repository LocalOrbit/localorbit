class Price < ActiveRecord::Base
  include SoftDelete

  audited allow_mass_assignment: true
  belongs_to :product, inverse_of: :prices
  belongs_to :market
  belongs_to :organization

  scope :view_sorted, lambda {
    visible
    .joins("LEFT JOIN markets ON prices.market_id = markets.id LEFT JOIN organizations ON prices.organization_id = organizations.id")
    .order("markets.name NULLS FIRST, organizations.name NULLS FIRST, min_quantity")
  }

  scope :for_product_and_market_and_org_at_time, lambda {|product, market, organization, order_time|
    where("product_id = ?", product.id)
    .where("updated_at <= ?", order_time)
    .where("deleted_at IS NULL OR deleted_at >= ?", order_time)
    .where("market_id IS NULL OR market_id = ?", market.id)
    .where("organization_id IS NULL OR organization_id = ?", organization.id)
  }

  scope :for_market_and_org, lambda { |market, organization|
    visible
    .where("market_id IS NULL OR market_id = ?", market.id)
    .where("organization_id IS NULL OR organization_id = ?", organization.id)
  }

  validates :min_quantity, :sale_price, presence: true, numericality: {greater_than: 0, less_than: 1_000_000, allow_blank: true}
  validates :min_quantity, uniqueness: {scope: [:product_id, :market_id, :organization_id, :deleted_at]}

  def net_price
    ((sale_price || 0) * net_percent).round(2)
  end

  def net_percent
    if product_fee_pct > 0
      1 - (product_fee_pct/100 + ::Financials::Pricing.seller_cc_rate(product.organization.all_markets.first))
    elsif market
      market.seller_net_percent
    else
      product.organization.all_markets.map{|mkt| mkt.seller_net_percent}.min
    end
  end

  def for_market_and_organization?(market, organization)
    (market_id.nil? || market_id == market.id) && (organization_id.nil? || organization_id == organization.id)
  end
end
