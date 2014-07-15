class MarketOrganization < ActiveRecord::Base
  include SoftDelete

  belongs_to :market
  belongs_to :organization
  belongs_to :cross_sell_origin_market, class_name: :Market

  scope :cross_selling, ->{ where.not(cross_sell_origin_market_id: nil) }
  scope :not_cross_selling, ->{ where(cross_sell_origin_market_id: nil) }
end
