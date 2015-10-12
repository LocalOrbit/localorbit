class DeliveryNote < ActiveRecord::Base
	audited allow_mass_assignment: true, associated_with: :cart
	include SoftDelete

	belongs_to :cart # inverse of anything? will this association work this way?

	validates :note, :supplier_org, :buyer_org, presence: true
	# validate for uniqueness on cart + supplier TODO

	def self.alphabetical_by_supplier_org
		order(supplier_org: :asc)
	end

	def note
		self.note 
	end

	def supplier_org
		self.supplier_org
	end

	def buyer_org
		self.buyer_org
	end

	def cart_id
		self.cart_id
	end

end