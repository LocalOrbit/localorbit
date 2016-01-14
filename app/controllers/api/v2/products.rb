module API
	module V2
		#extend self

		class ProductHelpers

			def self.identify_product_uniqueness(product_params) # takes hash of params
				# goes with an existing general product if it has the same name and category as another product --> then it gets that genprod's g_p_id
				# if unit and/OR unit description different -- but that's taken care of in original data, isn't it? 
				# I guess it isn't taken care of when you post straight JSON. TODO fix concern.
				identity_params_hash = {product_name:product_params[:name],category_id:get_category_id_from_name(product_params[:category])}
				gps = GeneralProduct.where(name:identity_params_hash[:product_name]).where(category_id:identity_params_hash[:category_id])#.empty? # TODO check 
				if !(gps.empty?)
					gps.first.id
				else
					false
				end
			end

			# TODO: limitations?? this will be somewhat better when it is limited but perhaps should limit to a depth like in original prod upload
			def self.get_category_id_from_name(category_name)
				id = Category.find_by_name(category_name).id # first?
				# return nil if no possible one
				id
			end

			def self.get_organization_id_from_name(organization_name)
				org = Organization.find_by_name(organization_name).id # first?
				org
			end

			def self.get_unit_id_from_name(unit_name) # assuming name is singular
				unit = Unit.find_by_singular(unit_name).id
				unit
			end
			
		end

		class SerializeProducts
			require 'csv'
			#extend self
			@required_headers = ["Organization","Product Name","Category","Short Description","Product Code","Unit Name","Unit Description","Price" "Multiple Pack Sizes","MPS Unit","MPS Unit Description","MPS Price"] # TODO figure out accurate naming for multi-unit/break-case stuff

			# takes a file (CSV, properly formatted re: headers, row data may or may not be invalid) returns JSON data (to be passed to a post route)
			def self.get_json_data(csvfile) # from - params[:filewhatever] from upload form, right?
				if self.validate_csv_catalog_file_format(csvfile)
					# somewhere need to ensure valid row
					product_rows = {}
					row_errors = {} # Collect errors here
					product_rows["products_total"] = csvfile.readlines.size # should be the number of lines of the file - TODO take a look at managing the file types in the pass to this method and using the CSV module
					product_rows["products"] = []
					CSV.foreach(csvfile.path, headers:true) do |row|
						if validate_product_row(row)
							product_row_hash = {}
							@required_headers[0..-4].each do |rh|
								product_row_hash[rh] = row[rh]
							end
							if row[@required_headers[-4]] == "Y" # TODO need more error checking?
								product_row_hash[@required_headers[-4]] = {}
								# Make sub-hash with the multi-unit/break case information if extant, based on order of required headers (makes sense for these to always come last, as in array above).
								product_row_hash[@required_headers[-4]][@required_headers[-3]] = row[@required_headers[-3]]
								product_row_hash[@required_headers[-4]][@required_headers[-2]] = row[@required_headers[-2]]
								product_row_hash[@required_headers[-4]][@required_headers.last] = row[@required_headers.last]
							else
								product_row_hash[@required_headers[-4]] = {} # Blank hash if there's no multi-unit/break case info
							end
							product_rows["products"] << product_row_hash
						else

						end
					end
				end
			end

			# takes a csvfile -- returns true if valid, false if invalid
			def self.validate_csv_catalog_file_format(csvfile)
				# check for CSV not XLS ## in upload form, use: file_field_tag :file, accept: '.csv'
				# check for 2 (1? probably 2) or more rows (see below)
				# check for correct headers (see below)
				# Need to put file errors somewhere on upload page response. TODO!
				headers = CSV.open(csvfile, 'r') { |csv| csv.first }
				if csvfile.readlines.size < 2
					return false
				end
				@required_headers[0..-4].each do |h|
					unless headers.include?(h)
						return false
					end
				end
				true
			end


			## PROBLEM: Current code has global relative dependency on errors hash and that's gross. 
			## TODO abstract this process into a class (within the module? another class right here?) so that it is less gross.
			## TODO this would be prettier in lib the way it did before but then it broke stuff. Change later.
			def self.validate_product_row(product_row)
				okay_flag = true
				error_hash = {}
				## TODO: is there any reasons this would be a problem for API process? Don't think so, this shouldn't be needed for anything outside verifying CSV files uploaded.
				error_hash["Row number"] = "TMP" # need the row number to identify where the problem is
				error_hash["Errors"] = {}
				if [product_row["Organization"], product_row["Product Name"],product_row["Category"],product_row["Short Description"],product_row["Unit Name"],product_row["Unit Description"],product_row["Price"],product_row[@required_headers[-4]]].any? {|obj| obj.blank?}
					okay_flag = false
					#create error and append it
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
				if get_category_id_from_name(product_row["Category"]).nil?
					okay_flag = false
					#create error and append it
					error_hash["Errors"]["Missing or invalid category"] = "Check category validity." # TODO need more information about category problems
				end
				if ProductHelpers.get_organization_id_from_name(product_row["Organization"]).nil?
					okay_flag = false
					#create error and append it
					error_hash["Errors"]["Missing or invalid Organization name"] = "Check organization validity." # TODO need more information
				end
				if ProductHelpers.get_unit_id_from_name(product_row["Unit Name"]).nil?
					okay_flag = false
					#create error and append it 
					error_hash["Errors"]["Missing or invalid Unit name"] = "Check unit of measure validity" # TODO need more information
				end
				if !(price.to_f and price.to_f > 0) 
					okay_flag = false
					#create error and append it
					error_hash["Errors"]["Missing or invalid price"] = "Check product price validity. Must be a valid decimal > 0."
				end
				if product_row[@required_headers[-4]].upcase != "Y" and !product_row[@required_headers.last].to_f > 0
					okay_flag = false
					error_hash["Errors"]["Missing or invalid price for additional pack size"] = "Check price validity for #{product_row[@required_headers.last}. Must be a valid decimal > 0."
				end
				if product_row[@required_headers[-4]].upcase != "Y" and [product_row[@required_headers[-3]],product_row[@required_headers[-2]],product_row[@required_headers.last]] == [product_row["Unit Name"],product_row["Unit Description"],product_row["Unit Price"]]
					okay_flag = false
					error_hash["Errors"]["Identical units for same product"] = "Your additional unit and original unit for this project are the same. Try again with different information in the last three columns OR do not submit additional unit information"
				end
				row_errors["#{error_hash["Row number"]}"] = error_hash
				return okay_flag # boolean as to whether there are any errors

				# Return true if checks all pass.

				# Append to row_errors hash the serialized version of the error set if any in current row, and return false.
			end

			## but this is already done . ^
			## def process_product_rows() - iterate over the rows, contain error and return serialized errors, use validate_product_row each time, and only call this if validate_csv_catalog_file_format is true
		end

		## API routes to mount

		class Products < Grape::API 
			include API::V2::Defaults
			#include API::V2::ProductHelpers
			#extend ProductHelpers

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
					supplier_id = possible_org.id
					unit_id = Unit.find_by_singular(permitted_params[:unit]).id
					category_id = Category.find_by_name(permitted_params[:category]).id
					product_code = ""
					if permitted_params[:code]
						product_code = permitted_params[:code]
					end
					## TODO here there also must be a determination of uniqueness and assignment of general product id OR creation of new general product and assignment of that id on this product
					gp_id_or_false = ProductHelpers.identify_product_uniqueness(permitted_params)
					if !gp_id_or_false
						product = Product.create!(
							        name: product_name,
							        organization_id: supplier_id,
							        #market_name: permitted_params[:market_name], # TODO check, will this relationship hold up? see: where p is a Product,
							    		## p.organization.markets.include?(Market.find_by_name(p.market_name))
											## => true
											### but also apparently,  -- market name not a prod attr?? TODO fix
							        unit_id: unit_id,
							        category_id: category_id,
							        code: product_code,
							        short_description: permitted_params[:short_description],
							        long_description: permitted_params[:long_description],
							        unit_description: permitted_params[:unit_description]
							      	)
						## To create inventory and price(s). -- probably no inventory, yes 1 sale price, yes?
						# product.lots.create!(quantity: 999_999)
	     			product.prices.create!(sale_price: permitted_params[:price], min_quantity: 1) ## TODO: Should we add min quantity default or option
	     		else
	     			product = Product.create!(
							        name: product_name,
							        organization_id: supplier_id,
							        #market_name: permitted_params[:market_name], # TODO check, will this relationship hold up? see: where p is a Product,
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
	     			product.prices.create!(sale_price: permitted_params[:price], min_quantity: 1) ## TODO: min quantity default or option?
	     		end
	     		{"result"=>"success?"} # TODO what should this actually be though
				end

				desc "Upload json"
				params do
					requires type: JSON # expects properly formatted JSON data
				end
				post '/add-products' do
					# do stuff with posted json file here
					# should be normal way of parsing it and then it will add by row
					
					def self.create_product_from_hash(prod_hash)
						gp_id_or_false = ProductHelpers.identify_product_uniqueness(prod_hash)
						if !gp_id_or_false
							product = Product.create!(
											name: prod_hash["Product Name"],
							        organization_id: get_organization_id_from_name(prod_hash["Organization"]),
							        #market_name: prod_hash["Market"],
							        unit_id: get_unit_id_from_name(prod_hash["Unit"]),
							        category_id: get_category_id_from_name(prod_hash["Category"]),
							        code: prod_hash["Product Code"],
							        short_description: prod_hash["Short Description"],
							        long_description: prod_hash["Long Description"],
							        unit_description: prod_hash["Unit Description"]
							      	)
							unless prod_hash[@required_headers[-4]].empty? # TODO not loving the repetition, this should be factored out for sure, but for now.
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
							        #market_name: prod_hash["Market"],
							        unit_id: get_unit_id_from_name(prod_hash["Unit"]),
							        category_id: get_category_id_from_name(prod_hash["Category"]),
							        code: prod_hash["Product Code"],
							        short_description: prod_hash["Short Description"],
							        long_description: prod_hash["Long Description"],
							        unit_description: prod_hash["Unit Description"],
							        general_product_id: gp_id_or_false
							      	)
							unless prod_hash[@required_headers[-4]].empty? # TODO not loving the repetition, but for now.
								newprod = product.dup 
								newprod.unit_id = get_unit_id_from_name(prod_hash[@required_headers[-3]])
								newprod.unit_description = prod_hash[@required_headers[-2]]
								#newprod.price = prod_hash[@required_headers.last] # no, prices need build on lots
								newprod.prices.create!(sale_price: price, min_quantity: 1)
								newprod.save! # for id to be created in db
							end
						end

					end # end def.self_create_product_from_hash
					{"result"=>"success?"} # TODO what should this actually be though
				end # end /post add-products (json)

			end

		end
	end
end

