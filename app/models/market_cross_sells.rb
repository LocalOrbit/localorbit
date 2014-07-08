class MarketCrossSells < ActiveRecord::Base
  belongs_to :market, class_name: "Market", foreign_key: :source_market_id
  belongs_to :cross_sell, class_name: "Market", foreign_key: :destination_market_id
end
