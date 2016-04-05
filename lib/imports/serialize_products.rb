module Imports
	module SerializeProducts
		require 'csv'
		@required_headers = ["Organization","Market Subdomain","Product Name","Category Name","Short Description","Product Code","Unit Name","Unit Description","Price", "Multiple Pack Sizes","MPS Unit","MPS Unit Description","MPS Price"] # Required headers for imminent future

		# TODO should this be a diff kind of accessor? Later, works.
		def self.required_headers
			@required_headers
		end

		def self.get_json_data(csvfile) # from - params[:filewhatever] from upload form
			$product_rows = {} # these are global
			$row_errors = {} # Collect errors here
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
							# Make sub-hash with the multi-unit/break case information if extant, based on order of required headers
							product_row_hash[@required_headers[-4]][@required_headers[-3]] = row[@required_headers[-3]]
							product_row_hash[@required_headers[-4]][@required_headers[-2]] = row[@required_headers[-2]]
							product_row_hash[@required_headers[-4]][@required_headers.last] = row[@required_headers.last]
						else
							product_row_hash[@required_headers[-4]] = {} # Blank hash if there's no multi-unit/break case info.
						end
						$product_rows["products"] << product_row_hash
					else
						# This is what happens if a row is invalid but the general format of the file is correct.
						# All rows should be displayed on upload. 
					end
					# TODO clarify return in diff scenarios
				end
				return $product_rows,$row_errors # array of these hashes
			else
			# Error handling
			# Return a message. TODO concern for redirects?
			$row_errors["0"] = "File format invalid. Upload requires a CSV with required headers." # TODO make this neater. 
			# OK that it is row 0 for now. Could be more specific with a "format" tag in yml/whatever and view tpl later.
			end
		end

		# takes a csvfile -- returns true if valid, false if invalid
		def self.validate_csv_catalog_file_format(csvfile)
			begin
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
			rescue
				$row_errors["0"] = "Invalid file format. Please try again with a valid .CSV file."
				return false
			end
		end

		def self.validate_product_row(product_row, line_num)
			okay_flag = true
			error_hash = {}
			## This shouldn't be needed for anything outside verifying CSV files uploaded. Check w
			error_hash["Row number"] = line_num.to_s 
			error_hash["Errors"] = {}
			if [product_row["Product Name"],product_row["Category Name"],product_row["Short Description"],product_row["Unit Name"],product_row["Unit Description"],product_row["Price"],product_row[@required_headers[-4]]].any? {|obj| obj.blank?}
				okay_flag = false
				#create error and append it (TODO could have clearer error info for this one - which one is blank)
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
			if ProductHelpers.get_organization_id_from_name(product_row["Organization"], product_row["Market Subdomain"]).nil?
				okay_flag = false
				#create error and append it
				error_hash["Errors"]["Missing or invalid Organization name"] = "Check organization and market validity. Do you have rights to upload to this organization in this market? You input: #{product_row["Organization"]},#{product_row["Market Subdomain"]}" # TODO more info provided?
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

			return okay_flag 
			# Should return true if checks all pass.
		end

	end
end