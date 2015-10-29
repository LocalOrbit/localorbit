class Admin::UploadController < AdminController
	require 'rubyXL'
  require 'open3'

  def index
    @plan = current_market.plan.name # check if LocalEyes plan on market
    current_mkt_id = current_market.id # ensures that current market sub-site matters for where upload occurs
  	sql = "select subdomain, id from markets where id in (select destination_market_id from market_cross_sells where source_market_id=#{current_mkt_id});"
  	records = ActiveRecord::Base.connection.execute(sql)
    @job_id = Time.now.to_i # send this to the audit
  	@suppliers_available = Hash.new
  	records.each do |r|
  		@suppliers_available[r['subdomain']] = {'market_id'=>r['id']}
  	end
  end

  
def upload
    @total_products_msg = "Loading not completed." # initial

    if params.has_key?(:datafile)
      profile = params[:profile]
      filepath = './tempfiles/' + params[:datafile].original_filename.to_s
      @job_id = params[:job_id]
      @user = current_user.id
      
      uploaded = params[:datafile] # Gets the xlsx data from form upload post request
      filepath = Rails.root.join('tempfiles',uploaded.original_filename)
      File.open(filepath, 'wb') do |file|
        file.write(uploaded.read) # Writes that data to the open filestream in the tempfiles fldr
      end

      # system calls the wrapper, run in the background, passing through the job_id
      system("./bin/import_wrapper #{@job_id} #{profile} #{filepath} #{@user} &") # first arg for import_wrapper
    end
  end

  def newjob
    @job_id = params[:job_id] # access this from the post
    # now try to find audit with job id
    aud = Audit.where(associated_id:@job_id)
    if not aud.first
      raise ActiveRecord::RecordNotFound
    end
    content = aud.first['comment'].split("|*|")
    error_text = content.first
    products_loaded = content.last.match(/(Loaded \d products!)/).captures.first
    get_output(error_text,products_loaded) # when this is complete, should render errors on check tpl page
    render(:layout => false)
  end


  def get_output(cli_call_result, products_loaded)
    #if params.has_key?(:datafile) # this is now handled elsewhere
  	@error_display = [] # initial
  	if cli_call_result.include?("Assuming file is invalid and bailing out")
  		@errors = [":reason: Invalid file. No upload. Check your data file headers."] # array in case we want to add more information, easier
  		@errors.each do |er|
  			reason = @errors.select{|ln| ln.start_with?(":reason:")} # selects from something different b/c no need to split the file error msg (this replaces file audit, poss permanently)
  			@error_display << {'name' => "<NONE>",'reason' => reason.first[8..-1]} 
  		end
  		@total_products_msg = "0 products." # 0 products have been uploaded if the file has bad headers. Could be factored out TODO.
  	elsif cli_call_result.include?("---")
			@errors = cli_call_result.split("---")[1..-1]
			@errors.each do |er|
				er_data = er.split("\n") # Pull apart YAML in the huge text string we now have.
        reason = er_data.select{|ln| ln.start_with?(":reason:")} 
				if reason.empty?
					reason = ["        No identifiable reason for error. Check your data file."] # 8 spaces for standard placement of text.
				end
				name = er_data.select{|ln| ln.include?(" name:")}
				@error_display << {'name' => name.first[8..-1] ,'reason' => reason.first[8..-1]} # Product name, error reason (do we want other things, line number is more effort for moment). 8..-1 because apparent standard char# inward for text from process.
			end 
    	@total_products_msg = "#{products_loaded}" # could be factored out TODO
  	else
  		@no_errors = "No errors! Hooray!"
  		@total_products_msg = "#{products_loaded}" #cli_call_result.split("Loaded").last
  	end
		return # want to send this data to the check tpl
		#end
  end

end