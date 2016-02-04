class MarketAddress < ActiveRecord::Base
  audited allow_mass_assignment: true, associated_with: :market
  include SoftDelete

  belongs_to :market, inverse_of: :addresses

  validates :address, :city, :state, :zip, :market, :country, presence: true

  acts_as_geocodable address: {street: :address, locality: :city, region: :state, postal_code: :zip, country: :country}

  before_save :ensure_single_default
  before_save :ensure_single_billing
  before_save :ensure_single_remit_to
  before_save :ensure_default_address_label

  def self.alphabetical_by_name
    order(name: :asc)
  end

  def ensure_default_address_label
  	if (not self.name) || self.name == ""
      self.name = "Default Address"
  	end
  end

  # Helper methods for before_save-s to ensure a single default/billing address per market.
  def falsify_all_others_default(mkt_addr_id)
    MarketAddress.where( default:true ).where(market_id:"#{mkt_addr_id}".to_i).each do |ma|
      if ma.id != self.id
        ma.default = false
        ma.save!
      end
    end
  end

  def falsify_all_others_billing(mkt_addr_id)
    MarketAddress.where( billing:true ).where(market_id:"#{mkt_addr_id}".to_i).each do |ma| 
      if ma.id != self.id
        ma.billing = false
        ma.save!
      end
    end
  end

  def falsify_all_others_remit_to(mkt_addr_id)
    MarketAddress.where( remit_to:true ).where(market_id:"#{mkt_addr_id}".to_i).each do |ma|
      if ma.id != self.id
        ma.remit_to = false
        ma.save!
      end
    end
  end

  def ensure_single_default
    if self.default # if the about to be saved market address is default
      falsify_all_others_default(self.market_id)
    end
  end

  def ensure_single_billing
    if self.billing 
      falsify_all_others_billing(self.market_id)
    end
  end

  def ensure_single_remit_to
    if self.remit_to
      falsify_all_others_remit_to(self.market_id)
    end
  end

end
