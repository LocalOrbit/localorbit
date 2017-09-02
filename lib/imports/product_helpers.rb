module Imports
	module ProductHelpers

		$current_user = Figaro.env.api_admin_user_id.to_i

		def self.identify_product_uniqueness(product_params)
			identity_params_hash = {product_name:product_params["Product Name"].strip, category_id: self.get_category_id_from_name(product_params["Category Name"].strip),organization_id: self.get_organization_id_from_name(product_params["Organization"].strip,product_params["Market Subdomain"],$current_user)}
			product_unit_identity_hash = {unit_name:product_params["Unit Name"], unit_quantity: product_params["Unit Quantity"]} #,unit_description:product_params["Unit Description"]} # right now we can't really control for same unit name, diff description; people will just have to bin the units and it's fine.
			if product_params["Product ID"].to_i > 0
				prd = Product.find(product_params["Product ID"].to_i)
				gps = GeneralProduct.where(id: prd["general_product_id"].to_i)
			else
				gps = GeneralProduct.where(category_id:identity_params_hash[:category_id]).where(name:identity_params_hash[:product_name]).where(organization_id:identity_params_hash[:organization_id])
			end
			if !gps.empty?
				gps.first.id
			else
				false
			end
		end

		def self.get_parent_product_id_from_name(product_name, organization_name, subdomain, current_user)
			begin
				p = Product.where(name: product_name.strip, organization_id: self.get_organization_id_from_name(organization_name.strip, subdomain, current_user))
				p[0].id
			rescue
				return nil
			end
		end

		def self.get_category_id_from_name(category_name)
			begin
				t = Category.arel_table
				id = Category.where(depth:2).where(t[:name].matches("#{category_name.strip}%")).first.id # Must be a depth 2 category, where names ought to be unique, so this should be an array of length 1.
				# TODO: address this problem, perhaps parse recursively?
				id
			rescue
				return nil
			end
		end

		def self.get_organization_id_from_name(organization_name, market_subdomain, current_user)
			begin
				mkt = Market.find_by_subdomain(market_subdomain)
				user = User.find(current_user.to_i)
				org = user.managed_organizations_within_market(mkt).where(name: "#{organization_name.strip}", org_type: 'S')

				#unless user.admin? || user.markets.include?(mkt)
				#	return nil
				#end
				#t = Organization.arel_table
				#org = Organization.where(t[:name].eq("#{organization_name.strip}"),t[:market_id].matches(mkt.id),t[:org_type].eq('S'))

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
				unit = Unit.where(t[:singular].matches("#{unit_name.strip}%"))
				# unit = Unit.find_by_singular(unit_name).id
				unit.first.id
			rescue
				return nil
			end
		end

		def self.create_product_from_hash(prod_hash,current_user, current_market)
			gp_id_or_false = self.identify_product_uniqueness(prod_hash)
			if !gp_id_or_false
				product = Product.create(
								name: prod_hash["Product Name"].strip,
				        organization_id: self.get_organization_id_from_name(prod_hash["Organization"],prod_hash["Market Subdomain"],current_user),
				        unit_id: self.get_unit_id_from_name(prod_hash["Unit Name"]),
				        category_id: self.get_category_id_from_name(prod_hash["Category Name"]),
				        code: prod_hash["Product Code"],
				        short_description: prod_hash["Short Description"],
				        long_description: prod_hash["Long Description"],
				        unit_description: prod_hash["Unit Description"],
								unit_quantity: prod_hash["Unit Quantity"],
								organic: prod_hash["Organic"],
								parent_product_id: self.get_parent_product_id_from_name(prod_hash["Parent Product Name"], prod_hash["Organization"], prod_hash["Market Subdomain"], current_user),
								use_simple_inventory: prod_hash["Lot Number"].nil?,
				)
				product.skip_validation = true
				product.consignment_market = current_market.is_consignment_market?
				product.save

					pr = product.prices.find_or_initialize_by(min_quantity: 1)
					pr.sale_price = prod_hash["Price"]
					pr.net_price = (!prod_hash["Net Price"].nil? && Float(prod_hash["Net Price"]) > 0) ? Float(prod_hash["Net Price"]) : 0
					pr.save

				if prod_hash["New Inventory"].to_i >= 0
					lt = product.lots.find_or_initialize_by(good_from: nil, expires_at: nil, number: prod_hash["Lot Number"].nil? ? nil : prod_hash["Lot Number"])
					lt.quantity = prod_hash["New Inventory"].to_i
					lt.save
				end

				#unless prod_hash[SerializeProducts.required_headers[-4]].empty? # TODO this should be factored out, later.
				#	newprod = product.dup
				#	newprod.unit_id = self.get_unit_id_from_name(prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-3]])
				#	newprod.unit_description = prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-2]]
				#	newprod.save!
				#	newprod.prices.create!(sale_price: prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-1]], min_quantity: 1)
				#end
			else
				if prod_hash["Product ID"].to_i > 0
					product = Product.find(prod_hash["Product ID"].to_i)
				else
					product = Product.where(name:prod_hash["Product Name"],category_id: self.get_category_id_from_name(prod_hash["Category Name"]),organization_id: self.get_organization_id_from_name(prod_hash["Organization"],prod_hash["Market Subdomain"],current_user),unit_id: self.get_unit_id_from_name(prod_hash["Unit Name"])).first # should be only one in resulting array if any, because this is searching for a product-unit combination
				end
				if !product.nil? # if there is a product-unit with this name, category, org
					product.skip_validation = true
					product.consignment_market = current_market.is_consignment_market?
					product.update_attributes!(name: prod_hash["Product Name"].strip,
																		 category_id: self.get_category_id_from_name(prod_hash["Category Name"]),
																		 unit_description: prod_hash["Unit Description"],
																		 unit_quantity: !prod_hash["Unit Quantity"].nil? ? rod_hash["Unit Quantity"] : product.unit_quantity,
																		 code: !prod_hash["Product Code"].nil? ? prod_hash["Product Code"] : product.code,
																		 short_description: prod_hash["Short Description"],
																		 long_description: !prod_hash["Long Description"].nil? ? prod_hash["Long Description"] : product.long_description,
																		 organic: !prod_hash["Organic"].nil? ? prod_hash["Organic"] : product.organic,
																		 parent_product_id: self.get_parent_product_id_from_name(prod_hash["Parent Product Name"], prod_hash["Organization"], prod_hash["Market Subdomain"], current_user))

					pr = product.prices.find_or_initialize_by(min_quantity: 1)
					pr.sale_price = prod_hash["Price"]
					pr.net_price = (!prod_hash["Net Price"].nil? && Float(prod_hash["Net Price"]) > 0) ? Float(prod_hash["Net Price"]) : 0
					if pr.valid?
						pr.save
					else
						puts "Error validating: #{pr.id}"
					end
					if prod_hash["New Inventory"].to_i >= 0
						lt = product.lots.find_or_initialize_by(good_from: nil, expires_at: nil, number: prod_hash["Lot Number"].nil? ? nil : prod_hash["Lot Number"])
						lt.quantity = prod_hash["New Inventory"].to_i
						lt.save
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
								unit_quantity: prod_hash["Unit Quantity"],
								organic: prod_hash["Organic"],
								parent_product_id: self.get_parent_product_id_from_name(prod_hash["Parent Product Name"], prod_hash["Organization"], prod_hash["Market Subdomain"], current_user),
								use_simple_inventory: prod_hash["Lot Number"].nil?
				      	)
					product.skip_validation = true
					product.consignment_market = current_market.is_consignment_market?
					product.save

					pr = product.prices.find_or_initialize_by(min_quantity: 1)
					pr.sale_price = prod_hash["Price"]
					pr.net_price = (!prod_hash["Net Price"].nil? && Float(prod_hash["Net Price"]) > 0) ? Float(prod_hash["Net Price"]) : 0
					pr.save

					if prod_hash["New Inventory"].to_i >= 0
						lt = product.lots.find_or_initialize_by(good_from: nil, expires_at: nil, number: prod_hash["Lot Number"].nil? ? nil : prod_hash["Lot Number"])
						lt.quantity = prod_hash["New Inventory"].to_i
						lt.save
					end

				end

				#unless prod_hash[SerializeProducts.required_headers[-4]].empty? # TODO factor out
				#	# Check if this other unit exists already for the GeneralProduct.
				#	# If not, create it. If so, update other info on it.
				#	newprod = Product.where(name:prod_hash["Product Name"],unit_id:self.get_unit_id_from_name(prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-3]]),organization_id:self.get_organization_id_from_name(prod_hash["Organization"],prod_hash["Market Subdomain"],current_user))

				#	if newprod.empty?
				#		newprod = product.dup
				#	else
				#		newprod = newprod.first
				#	end
				#	newprod.update_attributes(unit_id:self.get_unit_id_from_name(prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-3]]),unit_description: prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-2]])
				#	newprod.save!

				#	newprod.prices.find_or_initialize_by(min_quantity: 1) do |pr|
				#		pr.sale_price = prod_hash["Multiple Pack Sizes"][SerializeProducts.required_headers[-1]]
				#		pr.save!
				#	end
					
				#end
			end # end the major if/else/end 
			# (update or not, basically, wherein the additional unit/line is handled inside each case in the unless stmts)
		end # end def.self_create_product_from_hash

	end
end