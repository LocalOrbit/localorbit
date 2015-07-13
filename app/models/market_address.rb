class MarketAddress < ActiveRecord::Base
  audited allow_mass_assignment: true, associated_with: :market
  include SoftDelete

  belongs_to :market, inverse_of: :addresses

  validates :address, :city, :state, :zip, :market, presence: true

  acts_as_geocodable address: {street: :address, locality: :city, region: :state, postal_code: :zip}

  before_save :ensure_single_default
  before_save :ensure_single_billing
  before_save :ensure_default_address_label

  def self.alphabetical_by_name
    order(name: :asc)
  end

  def ensure_default_address_label
  	if (not self.name) || self.name == ""
      self.name = "Default Address"
  	end
  end

  def ensure_single_default
    if self.default # if the about to be saved market address is default
      unless market.addresses.select{|mkt| mkt if mkt.default == true}.empty?
        MarketAddress.where( default:true ).update_all( default:false)
      end
    end
  end

  def ensure_single_billing
    if self.billing # if the about to be saved mkt address is billing
      unless market.addresses.select{|mkt| mkt if mkt.billing == true}.empty?
        MarketAddress.where( billing:true ).update_all( billing:false)
      end
    end
  end
  
end
