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

		$current_user = 3919

		def self.identify_product_uniqueness(product_params)
			identity_params_hash = {product_name:product_params["Product Name"],category_id: self.get_category_id_from_name(product_params["Category Name"]),organization_id: self.get_organization_id_from_name(product_params["Organization"],product_params["Market Subdomain"],$current_user)}
			product_unit_identity_hash = {unit_name:product_params["Unit Name"]}#,unit_description:product_params["Unit Description"]} # right now we can't really control for same unit name, diff description; people will just have to bin the units and it's fine.
			gps = GeneralProduct.where(category_id:identity_params_hash[:category_id]).where(name:identity_params_hash[:product_name]).where(organization_id:identity_params_hash[:organization_id])
			# if !(gps.empty?)
			# 	prods = Product.where(general_product_id:gps.first).where(unit_id:get_unit_id_from_name(product_unit_identity_hash[:unit_name])) # bit brittle
			# 	if !(prods.length > 1)
			# 		[gps.first.id] + prods # return array of general product, product-unit things to update
			# 	else
			# 		gps.first.id # need a hash of gps and product
			# 	# update product itself if necessary, otherwise unit to GPS -- that's the part of ID not yet covered
			# 	end
			if !gps.empty?
				gps.first.id
			else
				false
			end
		end

		def self.get_category_id_from_name(category_name)
			begin
				t = Category.arel_table
				id = Category.where(t[:name].matches("#{category_name}%")).first.id # going on first, for oldest, at moment -- most likely correct.

				# TODO Check -- may improve with taxonomy restructure, May16 no category uniqueness by name only -- depends upon taxonomy + varying acceptable depths.
				# Previous sol'n, holding:
				# id = Category.find_by_name(category_name).id # works, but case sensitive
				id
			rescue
				return nil
			end
		end

		def self.get_organization_id_from_name(organization_name,market_subdomain,current_user)
			begin
				mkt = Market.find_by_subdomain(market_subdomain)
				user = User.find(current_user.to_i)
				unless user.admin? || user.markets.includes?(mkt)
					return nil
				end
				t = Organization.arel_table
				# org = Organization.find_by_name(organization_name)
				org = Organization.where(t[:name].matches("#{organization_name}%"),t[:market_id].matches(mkt.id),t[:can_sell].matches(true))

				if org.empty? # if none such that mkt and org match up
					return nil
				end
				org.first.id # if we get here, return ref to org id that comes up first
				# TODO check handling non-uniques properly
			rescue
				return nil
			end
		end

		def self.get_unit_id_from_name(unit_name) # assuming name is singular - this is input req
			begin
				t = Unit.arel_table
				unit = Unit.where(t[:singular].matches("#{unit_name}%"))
				# unit = Unit.find_by_singular(unit_name).id
				unit.first.id
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
				  product.prices.find_or_initialize_by(min_quantity: 1) do |pr|
						pr.sale_price = prod_hash["Price"]
						pr.save!
					end
				unless prod_hash[SerializeProducts.required_headers[-4]].empty? # TODO this should be factored out, later.
					newprod = product.dup 
					newprod.unit_id = self.get_unit_id_from_name(prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-3]])
					newprod.unit_description = prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-2]]
					newprod.save!
					newprod.prices.create!(sale_price: prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-1]], min_quantity: 1)
				end
			else 
				product = Product.where(name:prod_hash["Product Name"],category_id: self.get_category_id_from_name(prod_hash["Category Name"]),organization_id: self.get_organization_id_from_name(prod_hash["Organization"],prod_hash["Market Subdomain"],current_user),unit_id: self.get_unit_id_from_name(prod_hash["Unit Name"])).first # should be only one in resulting array if any, because this is searching for a product-unit combination
				if !product.nil? # if there is a product-unit with this name, category, org
					product.update_attributes!(unit_description: prod_hash["Unit Description"],code: prod_hash["Product Code"],short_description: prod_hash["Short Description"],long_description: prod_hash["Long Description"])
					# TODO update price 
					product.prices.find_or_initialize_by(min_quantity: 1) do |pr|
						pr.sale_price = prod_hash["Price"]
						pr.save!
					end
				else # if there is not such a unit, create a new prod-unit
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
					product.prices.find_or_initialize_by(min_quantity: 1) do |pr|
						pr.sale_price = prod_hash["Price"]
						pr.save!
					end
				end

				unless prod_hash[SerializeProducts.required_headers[-4]].empty? # TODO factor out
					# Check if this other unit exists already for the GeneralProduct.
					# If not, create it. If so, update other info on it.
					newprod = Product.where(name:prod_hash["Product Name"],unit_id:self.get_unit_id_from_name(prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-3]]),organization_id:self.get_organization_id_from_name(prod_hash["Organization"],prod_hash["Market Subdomain"],current_user))

					if newprod.empty?
						newprod = product.dup
					else
						newprod = newprod.first
					end
					newprod.update_attributes(unit_id:self.get_unit_id_from_name(prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-3]]),unit_description: prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-2]])
					newprod.save!

					newprod.prices.find_or_initialize_by(min_quantity: 1) do |pr|
						pr.sale_price = prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-1]]
						pr.save!
					end
					
				end
			end # end the major if/else/end 
			# (update or not, basically, wherein the additional unit/line is handled inside each case in the unless stmts)
		end # end def.self_create_product_from_hash

	end
end