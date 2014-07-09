class MarketOrganization < ActiveRecord::Base
  include SoftDelete

  belongs_to :market
  belongs_to :organization
  belongs_to :cross_sell_origin_market, class_name: :Market
end
