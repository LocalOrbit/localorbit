class DeliveryNote < ActiveRecord::Base
	audited allow_mass_assignment: true
	include SoftDelete

	validates :supplier_org, :buyer_org, presence: true

	def self.alphabetical_by_supplier_org
		order(supplier_org: :asc)
	end


end