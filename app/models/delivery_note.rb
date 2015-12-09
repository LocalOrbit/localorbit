class DeliveryNote < ActiveRecord::Base
	audited allow_mass_assignment: true
	include SoftDelete

	validates :supplier_org, :buyer_org, presence: true
	
  belongs_to :supplier, class_name: "Organization", foreign_key: "supplier_org"
  belongs_to :buyer, class_name: "Organization", foreign_key: "buyer_org"
	belongs_to :order

	def self.alphabetical_by_supplier_org
		order(supplier_org: :asc)
	end


end