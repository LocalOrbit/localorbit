class Market < ActiveRecord::Base
  validates :name, :subdomain, uniqueness: true

  has_many :managed_markets
  has_many :managers, through: :managed_markets, source: :user
end
