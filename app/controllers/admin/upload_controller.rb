class Admin::UploadController < AdminController
	require 'rubyXL'
  require 'open3'
  include API::V2 

  def index
    @plan = current_market.plan.name # check if LocalEyes plan on market
    @current_mkt_id = current_market.id #TODO maybe useful
    # @current_user = current_user # to pass along TODO
    # @products_avail = Product.where(organi

    ## no longer needed, TBD
  	#sql = "select subdomain, id from markets where id in (select destination_market_id from market_cross_sells where source_market_id=#{current_mkt_id});"
  	#records = ActiveRecord::Base.connection.execute(sql)
    # @job_id = Time.now.to_i # send this to the audit
  	# @suppliers_available = Hash.new
  	# records.each do |r|
  	# 	@suppliers_available[r['subdomain']] = {'market_id'=>r['id']}
  	# end
  end


  def upload
    if params.has_key?(:datafile)
      # pass the datafile to the method with the csv file
      jsn = API::V2::SerializeProducts.get_json_data(params[:datafile]) # product stuff, row errors
      @num_products_loaded = 0
      unless jsn.include?("invalid")
        jsn[0]["products"].each do |p|
          API::V2::ProductHelpers.create_product_from_hash(p)
          @num_products_loaded += 1
        end
        @errors = jsn[1]
      else
        @num_products_loaded = 0
        @errors = {"File"=>jsn}
      end
 
      # interface -> show number of products loaded and a link back to do whatever. plus, file errors and whatever

    end
  end

  

  # def newjob
  #   @job_id = params[:job_id] # access this from the post
  #   # now try to find audit with job id
  #   aud = Audit.where(associated_id:@job_id)
  #   if not aud.first
  #     raise ActiveRecord::RecordNotFound
  #   end
  #   content = aud.first['comment'].split("|*|")
  #   error_text = content.first
  #   products_loaded = content.last.match(/(Loaded \d+ products!)/).captures.first
  #   get_output(error_text,products_loaded) # when this is complete, should render errors on check tpl page
  #   render(:layout => false)
  # end
  

end