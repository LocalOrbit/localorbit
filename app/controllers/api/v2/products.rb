module API
	module V2
		class Products < Grape::API 
			include API::V2::Defaults

			resource :products do 
				# get requests
				desc "Return all products"
				get "", root: :products do 
					GeneralProduct.all # if you're actually looking for all products, this is what you want (TODO address: how will it deal with units?)
				end

				desc "Return a product"
				params do 
					requires :id, type: String, desc: "ID of the product"
				end
				get ":id", root: "product" do 
					Product.where(id: permitted_params[:id]).first!
				end

				desc "Return a product by name"
				params do 
					requires :name, type: String, desc: "Name of the product"
				end
				get ":name", root: "product" do 
					Product.where(name: permitted_params[:name]) # all that come up with that name search
				end

				desc "Return products by category"
				params do 
					requires :category, type: String, desc: "Name of category"
				end
				get ":category", root: "product" do # This one does not really work that well, eg category "carrots" gets all the cat "Vegetables", TODO examine priorities
					category_id = Category.find_by_name(permitted_params[:category]).id
					Product.where(category_id: category_id) # possible this should be genprod
				end

				### post requests

				desc "Create a product"
				params do
					requires :name, :organization_name, :market_name, :unit, :category, :unit_description, :short_description, :long_description, :price
				end

				# singular in post request
				post '/add-product' do
					product_name = permitted_params[:name]
					possible_orgs = Organization.find_by_name(permitted_params[:organization_name])
					supplier_id = possible_orgs.first.id # TODO better accuracy
					unit_id = Unit.find_by_name(permitted_params[:unit]).first.id
					category_id = get_category_id_from_name(permitted_params[:category])
					product_code = ""
					if permitted_params[:code]
						product_code = permitted_params[:code]
					end
					## TODO here there also must be a determination of uniqueness and assignment of general product id OR creation of new general product and assignment of that id on this product
					gp_id_or_false = identify_product_uniqueness(permitted_params)
					if !gp_id_or_false
						product = Product.create!(
							        name: product_name,
							        organization_id: supplier_id,
							        market_name: permitted_params[:market_name], # TODO check, will this relationship hold up? see: where p is a Product,
							    		## p.organization.markets.include?(Market.find_by_name(p.market_name))
											## => true

							        unit_id: unit_id,
							        category_id: category_id,
							        code: product_code,
							        short_description: permitted_params[:short_description],
							        long_description: permitted_params[:long_description],
							        unit_description: permitted_params[:unit_description]
							      	)
						## To create inventory and price(s). -- probably no inventory, yes 1 sale price, yes?
						# product.lots.create!(quantity: 999_999)
	     			product.prices.create!(sale_price: price, min_quantity: 1) ## TODO: Should we add min quantity default or option
	     		else
	     			product = Product.create!(
							        name: product_name,
							        organization_id: supplier_id,
							        market_name: permitted_params[:market_name], # TODO check, will this relationship hold up? see: where p is a Product,
							    		## p.organization.markets.include?(Market.find_by_name(p.market_name))
											## => true

							        unit_id: unit_id,
							        category_id: category_id,
							        code: product_code,
							        short_description: permitted_params[:short_description],
							        long_description: permitted_params[:long_description],
							        unit_description: permitted_params[:unit_description],
							        general_product_id: gp_id_or_false
							      	)
						## To create inventory and price(s). probably no inventory, yes 1 sale price
						# product.lots.create!(quantity: 999_999)
	     			product.prices.create!(sale_price: price, min_quantity: 1) ## TODO: min quantity default or option?
				end

				desc "Upload json"
				params do
					requires type: JSON # expects properly formatted JSON data
				end
				post '/add-products' do
					# do stuff with posted json file here
					# should be normal way of parsing it and then it will add by row
					# sending responses in the order with the route redirections as mentioned in plan

					# will need some of the helper functions here

					# in upload route we'll want to get the posted file and convert it to json.
					# assuming you just GET properly formatted json (which, whatever), THAT's what gets passed in to this route.

					# iterate over list in jsonfile["products"]
					# each one is a ruby-hash-from-json that reps one product
					# basically want to call the create product route on it
					# but it's probably better to create a method that creates a product from the json file, in terms of efficiency, rather than going to get another route or something.

					 # ["Organization","Market","Product Name","Category","Short Description","Product Code","Unit Name","Unit Description","Price" "Multiple Pack Sizes","MPS Unit","MPS Unit Description","MPS Price"]


					def self.create_product_from_hash(prod_hash)
						gp_id_or_false = identify_product_uniqueness(prod_hash)
						if !gp_id_or_false
							product = Product.create!(
							        name: prod_hash["Product Name"],
							        organization_id: get_organization_id_from_name(prod_hash["Organization"]),
							        market_name: prod_hash["Market"]
							        unit_id: get_unit_id_from_name(prod_hash["Unit"]),
							        category_id: get_category_id_from_name(prod_hash["Category"],
							        code: prod_hash["Product Code"],
							        short_description: prod_hash["Short Description"],
							        long_description: prod_hash["Long Description"],
							        unit_description: prod_hash["Unit Description"]
							      	)
							if !prod_hash[@required_headers[-4]].empty? # TODO not loving the repetition, this should be factored out for sure, but for now.
								newprod = product.dup 
								newprod.unit_id = get_unit_id_from_name(prod_hash[@required_headers[-3]])
								newprod.unit_description = prod_hash[@required_headers[-2]]
								newprod.prices.create!(sale_price: price, min_quantity: 1)
								newprod.save! # for id to be created in db
							end
						else
							product = Product.create!(
							        name: prod_hash["Product Name"],
							        organization_id: get_organization_id_from_name(prod_hash["Organization"]),
							        market_name: prod_hash["Market"]
							        unit_id: get_unit_id_from_name(prod_hash["Unit"]),
							        category_id: get_category_id_from_name(prod_hash["Category"],
							        code: prod_hash["Product Code"],
							        short_description: prod_hash["Short Description"],
							        long_description: prod_hash["Long Description"],
							        unit_description: prod_hash["Unit Description"],
							        general_product_id: gp_id_or_false
							      	)
							if !prod_hash[@required_headers[-4]].empty? # TODO not loving the repetition, but for now.
								newprod = product.dup 
								newprod.unit_id = get_unit_id_from_name(prod_hash[@required_headers[-3]])
								newprod.unit_description = prod_hash[@required_headers[-2]]
								#newprod.price = prod_hash[@required_headers.last] # no, prices need build on lots
								newprod.prices.create!(sale_price: price, min_quantity: 1)
								newprod.save! # for id to be created in db
							end
						end
					end # end def.self_create_product_from_hash

				end # end /post add-products (json)

			end

		end
	end
end
