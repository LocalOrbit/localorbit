module API
	module V2
		extend self

		# PRODUCT HELPERS

		# Determines whether this product needs a new GenProd or belongs to an existing one
		# Returns true if new GenProd is necessary, returns GenProd id if there exists one (this seems bad though, maybe should return false)
		def identify_product_uniqueness(product_params) # takes hash of params
		end

		# TODO: limitations?? this will be somewhat better when it is limited but perhaps should limit to a depth like in original prod upload
		def get_category_id_from_name(category_name)
			id = Category.find_by_name(category_name).first.id
			# return nil if no possible one
			id
		end

		def get_organization_id_from_name(organization_name)
		end

		## May not be necessary.
		# def get_market_id_from_name(market_name)
		# end

		
		

	end
end