module API
	module V2
		#extend self

		class ProductHelpers
			# This has to work for an individual hash, so it has to be for EACH PRODUCT in the all-products
			def self.identify_product_uniqueness(product_params) 
				identity_params_hash = {product_name:product_params["Product Name"],category_id:ProductHelpers.get_category_id_from_name(product_params["Category"])}
				product_unit_identity_hash = {unit_name:product_params["Unit"],unit_description:product_params["Unit Description"]}
				gps = GeneralProduct.where(name:identity_params_hash[:product_name]).where(category_id:identity_params_hash[:category_id])

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

			def self.get_organization_id_from_name(organization_name)
				begin
					org = Organization.find_by_name(organization_name).id
					org
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
					        organization_id: self.get_organization_id_from_name(prod_hash["Organization"]),
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
						newprod.unit_id = self.get_unit_id_from_name(prod_hash[SerializeProducts.required_headers[-3]])
						newprod.unit_description = prod_hash[SerializeProducts.required_headers[-2]]
						newprod.save!
						newprod.prices.create!(sale_price: prod_hash["Price"], min_quantity: 1)
						#newprod.save! # for id to be created in db. (TODO this may be affected by uniqueness constraints tba. not yet.)
					end
				else
					product = Product.create(
					        name: prod_hash["Product Name"],
					        organization_id: self.get_organization_id_from_name(prod_hash["Organization"]),
					        unit_id: self.get_unit_id_from_name(prod_hash["Unit Name"]),
					        category_id: self.get_category_id_from_name(prod_hash["Category Name"]),
					        code: prod_hash["Product Code"],
					        short_description: prod_hash["Short Description"],
					        long_description: prod_hash["Long Description"],
					        unit_description: prod_hash["Unit Description"],
					        general_product_id: gp_id_or_false
					      	)
						product.save!
					unless prod_hash[SerializeProducts.required_headers[-4]] == "N" # TODO factor out
						newprod = product.dup 
						newprod.unit_id = self.get_unit_id_from_name(prod_hash[SerializeProducts.required_headers[-3]])
						newprod.unit_description = prod_hash[SerializeProducts.required_headers[-2]]
						newprod.save! # must create id in db before creating prices
						newprod.prices.create!(sale_price: prod_hash["Price"], min_quantity: 1)
					end
				end

			end # end def.self_create_product_from_hash
	
		end

		class SerializeProducts
			require 'csv'
			@required_headers = ["Organization","Product Name","Category Name","Short Description","Product Code","Unit Name","Unit Description","Price", "Multiple Pack Sizes","MPS Unit","MPS Unit Description","MPS Price"] # Required headers for imminent future

			# TODO should this be a diff kind of accessor? Later, works.
			def self.required_headers
				@required_headers
			end

			# takes a file (CSV, properly formatted re: headers, row data may or may not be invalid) returns JSON data (to be passed to a post route)
			def self.get_json_data(csvfile) # from - params[:filewhatever] from upload form
				$product_rows = {} # these are global, so accessible in both below methods is OK
				$row_errors = {} # Collect errors here (see comment inside validate row fxn for expl of $row_errors format, for now.)
				if self.validate_csv_catalog_file_format(csvfile)
					$product_rows["products"] = []
					CSV.foreach(csvfile.path, headers:true).each_with_index do |row, i| # i is the index of the row in the file
						if validate_product_row(row, i) # if the row is valid (see method)
							# then build a hash for it
							product_row_hash = {}
							@required_headers[0..-4].each do |rh|
								product_row_hash[rh] = row[rh]
							end
							if row[@required_headers[-4]] == "Y" # TODO need any more error checking?
								product_row_hash[@required_headers[-4]] = {}
								# Make sub-hash with the multi-unit/break case information if extant, based on order of required headers (makes sense for these to always come last, as in array above).
								product_row_hash[@required_headers[-4]][@required_headers[-3]] = row[@required_headers[-3]]
								product_row_hash[@required_headers[-4]][@required_headers[-2]] = row[@required_headers[-2]]
								product_row_hash[@required_headers[-4]][@required_headers.last] = row[@required_headers.last]
							else
								product_row_hash[@required_headers[-4]] = {} # Blank hash if there's no multi-unit/break case info.
							end
							$product_rows["products"] << product_row_hash
						else
							# This is what happens if a row is invalid but the general format of the file is correct. Which should be... ? 
							# All rows should be displayed on upload. 
						end
						# TODO clarify return in diff scenarios?
					end
					return $product_rows,$row_errors # array of these hashes
				end
				# TODO error handling - should handle if the csv format is invalid somehow, break out of the process neatly. 
				# Return a message. TODO concern for redirects?
			end

			# takes a csvfile -- returns true if valid, false if invalid
			def self.validate_csv_catalog_file_format(csvfile)
				csvfile = CSV.parse(open(csvfile),headers:true)
				$product_rows["products_total"] = csvfile.size
				headers = csvfile.headers
				if csvfile.size < 1 # not counting headers -- if no data, false
					return false
				end
				@required_headers[0..-4].each do |h| # if all the required headers aren't here, false
					unless headers.include?(h)
						return false
					end
				end
				true
			end

			## TODO maybe abstract helpers properly to lib and include modules.

			def self.validate_product_row(product_row, line_num)
				okay_flag = true
				error_hash = {}
				## This shouldn't be needed for anything outside verifying CSV files uploaded. Check w
				error_hash["Row number"] = line_num.to_s 
				error_hash["Errors"] = {}
				if [product_row["Product Name"],product_row["Category Name"],product_row["Short Description"],product_row["Unit Name"],product_row["Unit Description"],product_row["Price"],product_row[@required_headers[-4]]].any? {|obj| obj.blank?}
					okay_flag = false
					#create error and append it (TODO could have clearer error info for this one - which is blank)
					error_hash["Errors"]["Invalid Data under required headers"] = "Required data is blank."
				end
				if product_row[@required_headers[-4]].upcase == "Y" and [product_row[@required_headers[-3]],product_row[@required_headers[-2]],product_row[@required_headers.last]].any? {|obj| obj.blank?}
					okay_flag = false
					#create error and append it
					error_hash["Errors"]["Missing multi-unit/break case data"] = "#{@required_headers[-4]} header has data 'Y' but is missing required Unit, Unit description, and/or Price"
				end
				if product_row[@required_headers[-4]].upcase != "N" and product_row[@required_headers[-4]].upcase != "Y"
					okay_flag = false
					# create error and append it
					error_hash["Errors"]["Invalid data for #{@required_headers[-4]}"] = "Data must be Y or N"
				end
				if ProductHelpers.get_category_id_from_name(product_row["Category Name"]).nil?
					okay_flag = false
					#create error and append it
					error_hash["Errors"]["Missing or invalid category"] = "Check category validity." # TODO should have more info provided about category problems
				end
				if ProductHelpers.get_organization_id_from_name(product_row["Organization"]).nil?
					okay_flag = false
					#create error and append it
					error_hash["Errors"]["Missing or invalid Organization name"] = "Check organization validity." # TODO more info provided?
				end
				if ProductHelpers.get_unit_id_from_name(product_row["Unit Name"]).nil?
					okay_flag = false
					#create error and append it 
					error_hash["Errors"]["Missing or invalid Unit name"] = "Check unit of measure validity" # TODO more info provided?
				end
				if !(product_row["Price"].to_f and product_row["Price"].to_f > 0) 
					okay_flag = false
					#create error and append it
					error_hash["Errors"]["Missing or invalid price"] = "Check product price validity. Must be a valid decimal > 0."
				end
				if product_row[@required_headers[-4]].upcase == "Y" and product_row[@required_headers.last].to_f <= 0
					okay_flag = false
					error_hash["Errors"]["Missing or invalid price for additional pack size"] = "Check price validity for #{product_row[@required_headers.last]}. Must be a valid decimal > 0."
				end
				if (product_row[@required_headers[-4]].upcase == "Y") and ([product_row[@required_headers[-3]],product_row[@required_headers[-2]],product_row[@required_headers.last]] == [product_row["Unit Name"],product_row["Unit Description"],product_row["Unit Price"]])
					okay_flag = false
					error_hash["Errors"]["Identical units for same product"] = "Your additional unit and original unit for this project are the same. Try again with different information in the last three columns OR do not submit additional unit information"
				end
				$row_errors["#{error_hash['Row number']}"] = error_hash
				# as a result of this, e.g, $row_errors["2"] evals to a hash of key-value simpledescr-detaileddescr of all errors from THAT ROW 
				# so $row_errors contains keys of all the rows in the csv w/ data if there are errors
				return okay_flag # boolean as to whether there are any errors.
				# Should return true if checks all pass.
			end
			
		end


		## API routes to mount

		class Products < Grape::API 
			include API::V2::Defaults

			resource :products do 
				# get requests
				desc "Return all products"
				get "", root: :products do 
					GeneralProduct.all # if you're actually looking for all products, this is what you want (TODO address issue: how should this GET deal with units?)
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
					GeneralProduct.where(category_id: category_id) # I think this should be genprod, since that's ~products~ as we generally represent, so for now it is.
				end


				### POST ROUTES

				desc "Create a product"
				params do
					requires :name, :organization_name, :unit, :category, :unit_description, :short_description, :long_description, :price
				end

				# singular in post request
				post '/add-product' do
					product_name = permitted_params[:name]
					possible_org = Organization.find_by_name(permitted_params[:organization_name])
					supplier_id = possible_org.id # TODO what are we doing with organizations in add products, is it the same?
					unit_id = Unit.find_by_singular(permitted_params[:unit]).id
					category_id = Category.find_by_name(permitted_params[:category]).id
					product_code = ""
					if permitted_params[:code]
						product_code = permitted_params[:code]
					end
					
					gp_id_or_false = ProductHelpers.identify_product_uniqueness(permitted_params)
					if !gp_id_or_false
						product = Product.create!(
							        name: product_name,
							        organization_id: supplier_id,
							        #TODO check: is market association being handled via organization? how should it be?
							        unit_id: unit_id,
							        category_id: category_id,
							        code: product_code,
							        short_description: permitted_params[:short_description],
							        long_description: permitted_params[:long_description],
							        unit_description: permitted_params[:unit_description]
							      	)
						## To create inventory and price(s). -- probably no inventory, yes 1 sale price, yes?
						# product.lots.create!(quantity: 999_999)
	     			product.prices.create!(sale_price: permitted_params[:price], min_quantity: 1) ## TODO: Should we add min quantity default or option in API, if so how?
	     		else
	     			product = Product.create!(
							        name:product_name,
							        organization_id:supplier_id,
							        #Same mkt assoc question, market name attr needed / how?
							        unit_id:unit_id,
							        category_id:category_id,
							        code:product_code,
							        short_description:permitted_params[:short_description],
							        long_description: permitted_params[:long_description],
							        unit_description: permitted_params[:unit_description],
							        general_product_id: gp_id_or_false
							      	)
						## To create inventory and price(s). probably no inventory, yes 1 sale price
						# product.lots.create!(quantity: 999_999)
	     			product.prices.create!(sale_price: permitted_params[:price], min_quantity: 1) ## TODO: min quantity default or option?
	     		end
	     		{"result"=>"product successfully created"} # TODO what should this actually be though
				end

				desc "Upload json"
				params do
					requires type: JSON # expects properly formatted JSON data
				end
				post '/add-products' do
					def self.create_product_from_hash(prod_hash)
						# binding.pry
						gp_id_or_false = ProductHelpers.identify_product_uniqueness(prod_hash)
						if !gp_id_or_false
							product = Product.create(
											name: prod_hash["Product Name"],
							        organization_id: ProductHelpers.get_organization_id_from_name(prod_hash["Organization"]),
							        #market_name: prod_hash["Market"], # TODO same question
							        unit_id: ProductHelpers.get_unit_id_from_name(prod_hash["Unit"]),
							        category_id: ProductHelpers.get_category_id_from_name(prod_hash["Category"]),
							        code: prod_hash["Product Code"],
							        short_description: prod_hash["Short Description"],
							        long_description: prod_hash["Long Description"],
							        unit_description: prod_hash["Unit Description"]
							      	)
							  product.save!
							unless prod_hash[SerializeProducts.required_headers[-4]] == "N" # TODO this should be factored out, but later.
								newprod = product.dup 
								newprod.unit_id = ProductHelpers.get_unit_id_from_name(prod_hash[SerializeProducts.required_headers[-3]])
								newprod.unit_description = prod_hash[SerializeProducts.required_headers[-2]]
								newprod.prices.create!(sale_price: price, min_quantity: 1)
								newprod.save! # for id to be created in db. (TODO this may be affected by uniqueness constraints tba. not yet.)
							end
						else
							product = Product.create(
							        name: prod_hash["Product Name"],
							        organization_id: ProductHelpers.get_organization_id_from_name(prod_hash["Organization"]),
							        #market_name: prod_hash["Market"], # TODO same Q as above, mkt assoc
							        unit_id: ProductHelpers.get_unit_id_from_name(prod_hash["Unit"]),
							        category_id: ProductHelpers.get_category_id_from_name(prod_hash["Category"]),
							        code: prod_hash["Product Code"],
							        short_description: prod_hash["Short Description"],
							        long_description: prod_hash["Long Description"],
							        unit_description: prod_hash["Unit Description"],
							        general_product_id: gp_id_or_false
							      	)
								product.save!
							unless prod_hash[SerializeProducts.required_headers[-4]] == "N" # TODO factor out
								newprod = product.dup 
								newprod.unit_id = ProductHelpers.get_unit_id_from_name(prod_hash[SerializeProducts.required_headers[-3]])
								newprod.unit_description = prod_hash[SerializeProducts.required_headers[-2]]
								#newprod.price = prod_hash[@required_headers.last] # no, prices need build on lots
								newprod.prices.create!(sale_price: price, min_quantity: 1)
								newprod.save! # for id to be created in db
							end
						end

					end # end def.self_create_product_from_hash
	
					if params.class == Hashie::Mash # this should be the alternative case
						prod_hashes = params
					else
						# this should be the 'normal' thing when you post a JSON /file/ as body per convention, Rails will put file in tempfile 
						prod_hashes = JSON.parse(File.read(params[:body][:tempfile]))
					end

					prod_hashes["products"].each do |p|
						self.create_product_from_hash(p)
					end

					{"result"=>"#{prod_hashes["products_total"]} products successfully created","errors"=>$row_errors} 
				end 
				# TODO fix: not upserting?, just adding another, which seems like a problem.
				# TODO see potential - unit description/name uniqueness identifier in ProductHelpers, maybe within id_product_uniqueness, maybe call within from a separate method on the class. ?
			end

		end
	end
end

