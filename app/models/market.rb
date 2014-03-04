class Market < ActiveRecord::Base
  validates :name, :subdomain, uniqueness: true

  before_save :clean_twitter_slug

  has_many :managed_markets
  has_many :managers, through: :managed_markets, source: :user

  has_many :market_organizations
  has_many :organizations, through: :market_organizations
  has_many :addresses, class_name: MarketAddress
  has_many :delivery_schedules, inverse_of: :market

  def clean_twitter_slug
    if twitter && twitter.match(/^@/)
      self.twitter = twitter[1..-1]
    end
  end

  def fulfillment_locations(default_name)
    addresses.order(:name).map {|a| [a.name, a.id] }.unshift([default_name, 0])
  end
end
