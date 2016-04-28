module Imports
	module ProductHelpers

		# method to titleize without capitalizing conjunctions
		# def self.titleize_specific(nm)
		# 	conjs = ["of","and","with","on","to"]
		# 	nm = nm.titleize 
		# 	nmb = ""
		# 	nm.split.each do |w|
		# 		if conjs.include?(w.downcase)
		# 			nmb += w.downcase
		# 		else
		# 			nmb += w
		# 		end
		# 		nmb += " "
		# 	end
		# 	nmb
		# end

		def self.identify_product_uniqueness(product_params)
			identity_params_hash = {product_name:product_params["Product Name"],category_id:ProductHelpers.get_category_id_from_name(product_params["Category Name"],organization_id:ProductHelpers.get_organization_id_from_name(product_params["Organization"]))}
			product_unit_identity_hash = {unit_name:product_params["Unit Name"]}#,unit_description:product_params["Unit Description"]} # right now we can't really control for same unit name, diff description; people will just have to bin the units and it's fine.
			gps = GeneralProduct.where(category_id:identity_params_hash[:category_id]).where(name:identity_params_hash[:product_name]).where(organization_id:identity_params_hash[:organization_id])
			if !(gps.empty?)
				prods = Product.where(general_product_id:gps.first).where(unit_id:get_unit_id_from_name(product_unit_identity_hash[:unit_name])) # bit brittle
				if !(prods.empty?)
					[gps.first.id,prods.first.id] # return array of general product, product-unit to update
				else
					gps.first.id # need a hash of gps and product
				# update product itself if necessary, otherwise unit to GPS -- that's the part of ID not yet covered
				end
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

		def self.get_organization_id_from_name(organization_name,market_subdomain,current_user)
			begin
				# binding.pry
				mkt = Market.find_by_subdomain(market_subdomain)
				user = User.find_by_id(current_user)
				unless user.admin? || user.markets.includes?(mkt)
					return nil
				end

				org = Organization.find_by_name(self.titleize_specific(organization_name))
				if org.is_a?(Array)
					org = org.where(markets: mkt) # where the mkt is included in the organization's markets
					if org.empty? # if none such that mkt and org match up
						return nil
					end
				end	
				org.id # if we get here, return ref to org id
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

		def self.create_product_from_hash(prod_hash,current_user)
			gp_id_or_false = self.identify_product_uniqueness(prod_hash)
			if !gp_id_or_false
				product = Product.create(
								name: prod_hash["Product Name"],
				        organization_id: self.get_organization_id_from_name(prod_hash["Organization"],prod_hash["Market Subdomain"],current_user),
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
			elsif !gp_id_or_false.is_a?(Array)
				product = Product.where(name:prod_hash["Product Name"],category_id: self.get_category_id_from_name(prod_hash["Category Name"]),organization_id: self.get_organization_id_from_name(prod_hash["Organization"],prod_hash["Market Subdomain"],current_user),unit_id: self.get_unit_id_from_name(prod_hash["Unit Name"])).first
				if !product.nil?
					product.update_attributes!(unit_description: prod_hash["Unit Description"],code: prod_hash["Product Code"],short_description: prod_hash["Short Description"],long_description: prod_hash["Long Description"])
				else
					product = Product.create(
								name: prod_hash["Product Name"],
				        organization_id: self.get_organization_id_from_name(prod_hash["Organization"],prod_hash["Market Subdomain"],current_user),
				        unit_id: self.get_unit_id_from_name(prod_hash["Unit Name"]),
				        category_id: self.get_category_id_from_name(prod_hash["Category Name"]),
				        code: prod_hash["Product Code"],
				        short_description: prod_hash["Short Description"],
				        long_description: prod_hash["Long Description"],
				        unit_description: prod_hash["Unit Description"],
				        general_product_id: gp_id_or_false
				      	)
				  product.save!
				else
					# if there already is such a product, update
					product = Product.find(gp_id_or_false[1].id)
					product.price = prod_hash["Price"]
					product.code = prod_hash["Product Code"]
					product.short_description = prod_hash["Short Description"]
					product.long_description = prod_hash["Long Description"]
					product.unit_description = prod_hash["Unit Description"]
					product.save!
				end

				unless prod_hash[SerializeProducts.required_headers[-4]].empty? # TODO factor out
					# TODO: this should be a hash read/parsing YML, for all the required headers stuff
					# newprod = product.dup
					newprod = Product.where(name:newprod.name,unit_id:self.get_unit_id_from_name(prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-3]]))
					if newprod.empty?
						newprod = product.dup
					end
					newprod.update_attributes(unit_id:self.get_unit_id_from_name(prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-3]]),unit_description: prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-2]])
					newprod.save!
					newprod.prices.create!(sale_price: prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-1]], min_quantity: 1)
				end
			end

		end # end def.self_create_product_from_hash

	end
end