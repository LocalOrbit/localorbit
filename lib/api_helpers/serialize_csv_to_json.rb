module API
	module V2
		require 'csv'
		extend self
		@required_headers = ["Organization","Market","Product Name","Category","Short Description","Product Code","Unit Name","Unit Description","Price" "Multiple Pack Sizes","MPS Unit","MPS Unit Description","MPS Price"] # TODO figure out accurate naming for multi-unit/break-case stuff

		# takes a file (CSV, properly formatted re: headers, row data may or may not be invalid) returns JSON data (to be passed to a post route)
		def get_json_data(csvfile) # from - params[:filewhatever] from upload form, right?
			if validate_csv_catalog_file_format(csvfile)
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
		def validate_csv_catalog_file_format(csvfile)
			# check for CSV not XLS ## in upload form, use: file_field_tag :file, accept: '.csv'
			# check for 2 (1? probably 2) or more rows (see below)
			# check for correct headers (see below)
			# Need to put file errors somewhere on upload page response. TODO!
			headers = CSV.open(csvfile, 'r') { |csv| csv.first }
			if csvfile.readlines.size < 2
				return false
			end
			@required_headers[0..-4].each do |h|
				if h not in headers
					return false
				end
			end
			true
		end


		## PROBLEM: Current code has global relative dependency on errors hash and that's gross. 
		## TODO abstract this process into a class within the module so that it is less gross.
		def validate_product_row(product_row)
			okay_flag = true
			error_hash = {}
			## TODO: is there any reasons this would be a problem for API process? Don't think so, this shouldn't be needed for anything outside verifying CSV files uploaded.
			error_hash["Row number"] = "TMP" # need the row number to identify where the problem is
			error_hash["Errors"] = {}
			if [product_row["Organization"] product_row["Market"],product_row["Product Name"],product_row["Category"],product_row["Short Description"],product_row["Unit Name"],product_row["Unit Description"],product_row["Price"],product_row[@required_headers[-4]]].any? {|obj| obj.blank?}
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
			if get_organization_id_from_name(product_row["Organization"]).nil?
				okay_flag = false
				#create error and append it
				error_hash["Errors"]["Missing or invalid Organization name"] = "Check organization validity." # TODO need more information
			end
			if get_unit_id_from_name(product_row["Unit Name"]).nil?
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
			row_errors["#{error_hash["Row number"]}"] = error_hash
			return okay_flag # boolean as to whether there are any errors

			# Return true if checks all pass.

			# Append to row_errors hash the serialized version of the error set if any in current row, and return false.
		end

		# def process_product_rows() - iterate over the rows, contain error and return serialized errors, use validate_product_row each time, and only call this if validate_csv_catalog_file_format is true

	end
end