class MarketAddress < ActiveRecord::Base
  include SoftDelete

  belongs_to :market, inverse_of: :addresses

  validates :name, presence: true
  validates_uniqueness_of :name, conditions: -> { where('deleted_at != null') }
  validates :address, :city, :state, :zip, :market, presence: true

  acts_as_geocodable address: {street: :address, locality: :city, region: :state, postal_code: :zip}

  def self.alphabetical_by_name
    order(name: :asc)
  end

end
