class Admin::UploadController < AdminController
	require 'rubyXL'
  require 'open3'
  #require 'HTTParty'
  # include HTTParty
  # debug_output $stderr
  include API::V2 # hm

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
    if params.has_key?(:datafile)
      # pass the datafile to the method with the csv file
      #sp = API::V2::SerializeProducts.new
      # binding.pry
      jsn = API::V2::SerializeProducts.get_json_data(params[:datafile]) # product stuff, row errors
      # @num_products_loaded = jsn[0]["products_total"] - jsn[0]["products"].length
      # That will not work for number of products loaded, need a better
      # binding.pry
      jsn[0]["products"].each do |p|
        API::V2::ProductHelpers.create_product_from_hash(p)
      end
      # this works! yay! now have to handle sending the row errors display to the display, otherwise recustomizing the interface
      @errors = jsn[1]





      # HTTParty.post("#{request.base_url}/api/v2/products/add-products", :body => jsn[0]["products"])
      
      # binding.pry
      # HTTParty.post("#{request.base_url}/api/v2/products/add-products", :body => jsn[0])


      #POST "/api/v2/add-products" # post the jsn[0], + deal with the jsn[1] stuff

      #    example:     @result = HTTParty.post(@urlstring_to_post.to_str, :body => {:subject => 'This is the screen name', :issue_type => 'Application Problem', :status => 'Open', :priority => 'Normal', :description => 'This is the description for the problem'})



      # problem here is that the method opens a file that's already open -- deal with in SerializeProducts
      #binding.pry 

      # For the errors -- want to show:
      # Number of products loaded: products_total integer minus the length of the list in key "products"

      # For each row number in errors that has a non-empty value of "Errors" key (non-empty hash..)
      # indent or something after "Row <whatever number" and show each error
      # TODO: maybe it's easy to add in the info that's found about that one.

      # But we have access to them so can pass them through to the view.
      # And if it's all set,

      # Regardless -- show number of products loaded and a link back to do whatever.

    end
  end

  
# def upload
#     @total_products_msg = "Loading not completed." # initial

#     if params.has_key?(:datafile)
#       profile = params[:profile]
#       filepath = './tempfiles/' + params[:datafile].original_filename.to_s
#       @job_id = params[:job_id]
#       @user = current_user.id
      
#       uploaded = params[:datafile] # Gets the xlsx data from form upload post request
#       filepath = Rails.root.join('tempfiles',uploaded.original_filename)
#       File.open(filepath, 'wb') do |file|
#         file.write(uploaded.read) # Writes that data to the open filestream in the tempfiles fldr
#       end

#       # system calls the wrapper, run in the background, passing through the job_id
#       system("./bin/import_wrapper #{@job_id} #{profile} #{filepath} #{@user} &") # first arg for import_wrapper
#     end
#   end

  def newjob
    @job_id = params[:job_id] # access this from the post
    # now try to find audit with job id
    aud = Audit.where(associated_id:@job_id)
    if not aud.first
      raise ActiveRecord::RecordNotFound
    end
    content = aud.first['comment'].split("|*|")
    error_text = content.first
    products_loaded = content.last.match(/(Loaded \d+ products!)/).captures.first
    get_output(error_text,products_loaded) # when this is complete, should render errors on check tpl page
    render(:layout => false)
  end

  # todo will need a new get_output function that handles the errors stuff
  # and things

  
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