class MarketAddress < ActiveRecord::Base
  audited allow_mass_assignment: true, associated_with: :market
  include SoftDelete

  belongs_to :market, inverse_of: :addresses

  before_save :ensure_default_address_label

  #validates :name, presence: true, uniqueness: {scope: [:market_id, :deleted_at]}
  validates :address, :city, :state, :zip, :market, presence: true

  acts_as_geocodable address: {street: :address, locality: :city, region: :state, postal_code: :zip}

  def self.alphabetical_by_name
    order(name: :asc)
  end

  def ensure_default_address_label
  	if (not self.name) || self.name == ""
  		self.name = "Default Address"
  	end
  end

end
