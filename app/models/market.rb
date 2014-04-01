class Market < ActiveRecord::Base
  validates :name, :subdomain, uniqueness: true

  before_save :clean_twitter_slug

  has_many :managed_markets
  has_many :managers, through: :managed_markets, source: :user

  has_many :market_organizations
  has_many :organizations, through: :market_organizations
  has_many :addresses, class_name: MarketAddress
  has_many :delivery_schedules, inverse_of: :market

  has_many :bank_accounts, as: :bankable

  dragonfly_accessor :logo

  def clean_twitter_slug
    if twitter && twitter.match(/^@/)
      self.twitter = twitter[1..-1]
    end
  end

  def fulfillment_locations(default_name)
    addresses.order(:name).map {|a| [a.name, a.id] }.unshift([default_name, 0])
  end

  def domain
    "#{subdomain}.#{Figaro.env.domain!}"
  end

  def seller_net_percent
    BigDecimal("1") - (local_orbit_seller_fee + market_seller_fee) / 100
  end
end
