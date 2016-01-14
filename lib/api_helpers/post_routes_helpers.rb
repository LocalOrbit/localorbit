# module API
# 	module V2
		extend self

		# PRODUCT HELPERS

		# Determines whether this product needs a new GenProd or belongs to an existing one
		# Returns false if new GenProd is necessary, returns GenProd id if there exists one (binary, for useful control statements)
		class ProductHelpers

			def identify_product_uniqueness(product_params) # takes hash of params
				# goes with an existing general product if it has the same name and category as another product --> then it gets that genprod's g_p_id
				# if unit and/OR unit description different -- but that's taken care of in original data, isn't it? 
				# I guess it isn't taken care of when you post straight JSON. TODO fix concern.
				identity_params_hash = {product_name:product_params[:name],category_id:get_category_id_from_name(product_params[:category])}
				gps = GeneralProduct.where(name:identity_params_hash[:product_name] and category_id:identity_params_hash[:category_id]).empty? # TODO check 
				if !gps.empty?
					gps.first.id
				else
					false
				end
			end

			# TODO: limitations?? this will be somewhat better when it is limited but perhaps should limit to a depth like in original prod upload
			def get_category_id_from_name(category_name)
				id = Category.find_by_name(category_name).first.id # first?
				# return nil if no possible one
				id
			end

			def get_organization_id_from_name(organization_name)
				org = Organization.find_by_name(organization_name).first.id # first?
				org
			end

			def get_unit_id_from_name(unit_name) # assuming name is singular
				unit = Unit.find_by_singular(unit_name).id
				unit
			end

			## May not be necessary.
			# def get_market_id_from_name(market_name)
			# end
			
		end

# 	end
# end