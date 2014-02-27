class MarketAddress < ActiveRecord::Base
  belongs_to :market, inverse_of: :addresses

  validates :name, presence: true, uniqueness: { scope: :market_id }
  validates :address, :city, :state, :zip, :market, presence: true

  def self.alphabetical_by_name
    order(name: :asc)
  end
end

