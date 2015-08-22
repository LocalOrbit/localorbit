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
			cli_call_result = `./bin/import_products standard_template -p #{profile} -f '#{filepath}' 2>&1` # 2> error_file`#{}2> #{profile}_errors_#{DateTime.now}.yml` # saves a YAML file of errors which needs to be parsed and rendered
    	#@total_products_msg = cli_call_result


    	if cli_call_result.include?("---")
				@errors = cli_call_result.split("---")[1..-1]
				# split, 2 and -3 indexes
				@error_display = []
				@errors.each do |er|
					er_data = er.split("\n")
					reason = er_data.select{|ln| ln.start_with?(":reason:")} 
					reason ||= "Unspecified reason for error."
					name = er_data.select{|ln| ln.include?(" name:")}
					name ||= "Could not find product name/line with error. Check data file."
					@error_display << {'name' => name.first[8..-1] ,'reason' => reason.first[8..-1]} # Product name, error reason (do we want other things)
				end # this actually doesn't work depending on the errors. have to do actual validation of the rows by chars, which is better anyway. prod name col, reason? other things? todo decide, pick name and reason initially
    		@total_products_msg = cli_call_result.split("Loaded").last#.scan(/(Loaded %d+ products!)/) # todo fix this
    	else
    		@no_errors = "No errors! Hooray!"
    		@total_products_msg = cli_call_result.split("---").first
    	end
    	#.scan(/(Loaded %d+ products!)/)
    	#ryan_string.scan(/(^.*)(:)(.*)/i)
    	# then (maybe in another method) try to import it from the location and render errors + how many have been uploaded
    	return
		end
  end


end