module Imports
	module ProductHelpers

		def self.identify_product_uniqueness(product_params) 
			identity_params_hash = {product_name:product_params["Product Name"],category_id:ProductHelpers.get_category_id_from_name(product_params["Category Name"])}
			product_unit_identity_hash = {unit_name:product_params["Unit Name"],unit_description:product_params["Unit Description"]}
			gps = GeneralProduct.where(category_id:identity_params_hash[:category_id]).where(name:identity_params_hash[:product_name])
			if !(gps.empty?)
				gps.first.id
			else
				false
			end
		end

		def self.get_category_id_from_name(category_name)
			begin
				id = Category.find_by_name(category_name).id
				id
			rescue
				return nil
			end
		end

		def self.get_organization_id_from_name(organization_name,market_subdomain)
			# binding.pry
			begin
				mkt = Market.find_by_subdomain(market_subdomain)
				unless current_user.admin? || current_user.markets.includes?(mkt)
					return nil
				end

				org = Organization.find_by_name(organization_name)
				if org.is_a?(Array)
					org = org.where(markets: mkt) # where the mkt is included in the organization's markets
					if org.empty? # if none such that mkt and org match up
						return nil
					end
				end	
				org.id # if we get here, return ref to org id (right?)
			rescue
				return nil
			end
		end

		def self.get_unit_id_from_name(unit_name) # assuming name is singular
			begin
				unit = Unit.find_by_singular(unit_name).id
				unit
			rescue
				return nil
			end
		end

		def self.create_product_from_hash(prod_hash)
			gp_id_or_false = self.identify_product_uniqueness(prod_hash)
			if !gp_id_or_false
				product = Product.create(
								name: prod_hash["Product Name"],
				        organization_id: self.get_organization_id_from_name(prod_hash["Organization"],prod_hash["Market Subdomain"]),
				        unit_id: self.get_unit_id_from_name(prod_hash["Unit Name"]),
				        category_id: self.get_category_id_from_name(prod_hash["Category Name"]),
				        code: prod_hash["Product Code"],
				        short_description: prod_hash["Short Description"],
				        long_description: prod_hash["Long Description"],
				        unit_description: prod_hash["Unit Description"]
				      	)
				  product.save!
				unless prod_hash[SerializeProducts.required_headers[-4]].empty? # TODO this should be factored out, later.
					newprod = product.dup 
					newprod.unit_id = self.get_unit_id_from_name(prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-3]])
					newprod.unit_description = prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-2]]
					newprod.save!
					newprod.prices.create!(sale_price: prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-1]], min_quantity: 1)
				end
			else
				product = Product.where(name:prod_hash["Product Name"],category_id: self.get_category_id_from_name(prod_hash["Category Name"]),organization_id: self.get_organization_id_from_name(prod_hash["Organization"],prod_hash["Market Subdomain"]),unit_id: self.get_unit_id_from_name(prod_hash["Unit Name"])).first
				if !product.nil?
					product.update_attributes!(unit_description: prod_hash["Unit Description"],code: prod_hash["Product Code"],short_description: prod_hash["Short Description"],long_description: prod_hash["Long Description"])
				else
					product = Product.create(
								name: prod_hash["Product Name"],
				        organization_id: self.get_organization_id_from_name(prod_hash["Organization"],prod_hash["Market Subdomain"]),
				        unit_id: self.get_unit_id_from_name(prod_hash["Unit Name"]),
				        category_id: self.get_category_id_from_name(prod_hash["Category Name"]),
				        code: prod_hash["Product Code"],
				        short_description: prod_hash["Short Description"],
				        long_description: prod_hash["Long Description"],
				        unit_description: prod_hash["Unit Description"],
				        general_product_id: gp_id_or_false
				      	)
				  product.save!
				end

				# weird case: what if the new unit is brand new and not an update? TODO test check
				unless prod_hash[SerializeProducts.required_headers[-4]].empty? # TODO factor out
					# TODO: this should be a hash read/parsing YML, for all the required headers stuff
					newprod = product.dup
					newprod.update_attributes(unit_id:self.get_unit_id_from_name(prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-3]]),unit_description: prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-2]])
					newprod.save!
					newprod.prices.create!(sale_price: prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-1]], min_quantity: 1)
				end
			end

		end # end def.self_create_product_from_hash

	end
end