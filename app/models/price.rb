class Price < ActiveRecord::Base
  include SoftDelete
  after_save :update_product_record

  audited allow_mass_assignment: true
  belongs_to :product, inverse_of: :prices
  belongs_to :market
  belongs_to :organization

  scope :view_sorted, lambda {
    visible
    .joins("LEFT JOIN markets ON prices.market_id = markets.id LEFT JOIN organizations ON prices.organization_id = organizations.id")
    .order("markets.name NULLS FIRST, organizations.name NULLS FIRST, min_quantity")
  }

  scope :view_sorted_export, lambda {
    visible
        .joins("LEFT JOIN markets ON prices.market_id = markets.id LEFT JOIN organizations ON prices.organization_id = organizations.id")
        .where("prices.market_id is null and prices.organization_id is null AND min_quantity = 1")
  }

  scope :for_product_and_market_and_org_at_time, lambda {|product, market, organization, order_time|
    where("product_id = ?", product.id)
    .where("updated_at <= ?", order_time)
    .where("deleted_at IS NULL OR deleted_at >= ?", order_time)
    .where("market_id IS NULL", market.id)
    .where("organization_id IS NULL", organization.id)
  }

  scope :for_product_and_market_and_org_at_time_specific, lambda {|product, market, organization, order_time|
    where("product_id = ?", product.id)
        .where("updated_at <= ?", order_time)
        .where("deleted_at IS NULL OR deleted_at >= ?", order_time)
        .where("
          (market_id = :market_id) AND (organization_id = :organization_id) OR
          (market_id IS NULL) AND (organization_id = :organization_id) OR
          (market_id = :market_id) AND (organization_id IS NULL)
        ", market_id: market.id, organization_id: organization.id)
  }

  scope :for_market_and_org, lambda { |market, organization|
    visible
    .where("market_id IS NULL OR market_id = ?", market.id)
    .where("organization_id IS NULL OR organization_id = ?", organization.id)
  }

  validates :min_quantity, :sale_price, presence: true, numericality: {greater_than: 0, less_than: 1_000_000, allow_blank: true}
  validates :min_quantity, uniqueness: {scope: [:product_id, :market_id, :organization_id, :deleted_at]}

  def update_product_record
    product.touch
  end

  def net_price(market=nil, pct_array=nil)
    ((sale_price || 0) * net_percent(market, pct_array)).round(2)
  end

  def net_percent(curr_market=nil, pct_array=nil)
    mkt_id = nil
    if !curr_market.nil? || (curr_market.nil? && !pct_array.nil? && pct_array.length > 1)
      mkt_id = !pct_array.nil? && pct_array.length == 2 ? pct_array.keys[0] : !curr_market.nil? ? curr_market.id : nil
    end
    if product_fee_pct > 0
      1 - (product_fee_pct/100 + ::Financials::Pricing.seller_cc_rate(product.organization.all_markets.first))
    elsif !mkt_id.nil? && product.category.level_fee(mkt_id) > 0
      1 - (product.category.level_fee(mkt_id)/100 + ::Financials::Pricing.seller_cc_rate(product.organization.all_markets.first))
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
