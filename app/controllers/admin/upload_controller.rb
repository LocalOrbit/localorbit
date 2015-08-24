class Admin::UploadController < AdminController
	require 'rubyXL'

  def upload
  	uploaded = params[:datafile] # gets the xlsx data (or should) from form upload post req
  	filepath = Rails.root.join('tempfiles',uploaded.original_filename)
	  File.open(filepath, 'wb') do |file|
	  	file.write(uploaded.read) # writes that data to the open filestream in the tempfiles fldr
	  end
	end

  def index
  	# TODO more general SQL such that you can reasonably select a domain...
  	sql = "select subdomain, id from markets where id in (select destination_market_id from market_cross_sells where source_market_id=112);"
  	records = ActiveRecord::Base.connection.execute(sql)
  	@suppliers_available = Hash.new
  	records.each do |r|
  		@suppliers_available[r['subdomain']] = {'market_id'=>r['id']}
  	end
  end

  def check
  	@errors = []
  	@total_products_msg = "Loaded 0 products." # tmp, add later
  	if params.has_key?(:datafile)
  		profile = params[:profile]
  		filepath_partial = params[:datafile].original_filename
  		filepath = './tempfiles/' + filepath_partial.to_s
  		error_file = "./tempfiles/#{profile}_errors_#{Date.today}.yml" # will cause file errors if run around midnight, TODO fix
  		# would be nice to audit contents here (like headers). right now let's run it as we were doing before.
			upload # call the upload method to write file to tempfiles
			 # todo: make sure profiles possible are generated and available in form from controller instead of typed into the template
			cli_call_result = `./bin/import_products standard_template -p #{profile} -f '#{filepath}' 2>&1` 

    	@error_display = []
    	if cli_call_result.include?("Assuming file is invalid and bailing out")
    		@errors = [":reason: Invalid file. No upload. Check your data file headers."] # array in case we want to add more information, easier to add
    		@errors.each do |er|
    			reason = @errors.select{|ln| ln.start_with?(":reason:")} # selects from something different b/c no need to split the file error msg (this replaces file audit, poss permanently)
    			@error_display << {'name' => "<NONE>",'reason' => reason.first[8..-1]} 
    		end
    		@total_products_msg = "0 products."
    	elsif cli_call_result.include?("---")
				@errors = cli_call_result.split("---")[1..-1]
				@errors.each do |er|
					er_data = er.split("\n")
					reason = er_data.select{|ln| ln.start_with?(":reason:")} 
					if reason.empty?
						reason = ["        No identifiable reason for error. Check your data file."]
					end
					name = er_data.select{|ln| ln.include?(" name:")}
					@error_display << {'name' => name.first[8..-1] ,'reason' => reason.first[8..-1]} # Product name, error reason (do we want other things, line number is more effort for moment)
				end 
	    	@total_products_msg = cli_call_result.split("Loaded").last
    	else
    		@errors = nil
    		@no_errors = "No errors! Hooray!"
    		@total_products_msg = cli_call_result.split("Loaded").last
    	end
			return
		end
  end


end