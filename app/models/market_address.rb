class MarketAddress < ActiveRecord::Base
  audited allow_mass_assignment: true, associated_with: :market
  include SoftDelete

  belongs_to :market, inverse_of: :addresses

  validates :name, presence: true, uniqueness: {scope: [:market_id, :deleted_at]}
  validates :address, :city, :state, :zip, :market, presence: true 

  acts_as_geocodable address: {street: :address, locality: :city, region: :state, postal_code: :zip}

  before_save :ensure_single_default
  before_save :ensure_single_billing

  def self.alphabetical_by_name
    order(name: :asc)
  end

  # ok -- things possible to validate are self. attrs? 
  # if so the checks in the following for before_save s should work (?)

  # or: should set first's default to true? 
  # this is worth reviewing/testing

  def ensure_single_default
  	if self.default
  		market.addresses.map{|mkt| mkt.default = false}
  	end
  end

  def ensure_single_billing
  	if self.billing
  		market.addresses.map{|mkt| mkt.billing = false}
  	end
  end

end
