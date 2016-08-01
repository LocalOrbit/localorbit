class Admin::UploadController < AdminController
	require 'rubyXL'
  require 'open3'
  require './lib/Jobs/productupload.rb' 
  # include API::V2
  include Imports
  include Jobs

  def index
    @plan = current_market.organization.plan.name # check if LocalEyes plan on market
    @sd = current_market.subdomain
    @current_mkt_id = current_market.id #TODO maybe useful
    # code for mapping organization and ensuring sign-in authenticated upload
    @org_ids = current_user.organizations.map(&:id)
    @curr_user = current_user.id # to pass along, will find user by id in get_org method


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

  def download
    send_file(
      "#{Rails.root}/app/assets/download_files/LocalOrbit_product_upload_template.csv",
      filename: "LocalOrbit_product_upload_template.csv",
      type: "application/text"
    )
  end

  def get_documentation
    # download pdf or render it in-app? going with download at first because of how browsers work (that's why this is a separate route; it could be combined into download)
    send_file(
      "#{Rails.root}/app/assets/docs_files/Documentation_Product_Upload_May2016.pdf",
      filename: "Documentation_Product_Upload_Apr8-2016.pdf",
      type: "application/pdf"
    )
  end

  def upload
    if params.has_key?(:datafile)
      # TODO here: mimic the existing fxn-ality, in a delayed job
      aud = Audit.create!(user_id:current_user.id,action:"Product upload") # the id of this audit is what should trigger the job
      @num_products_loaded = 0
      jsn = ::Imports::SerializeProducts.get_json_data(params[:datafile],params[:curr_user]) # product stuff, row 
      @num_products_loaded = 0
      @errors = nil
      @curr_user = params[:curr_user] # to pass along
      Delayed::Job.enqueue(::Jobs::ProductUpload::ProductUploadJob.new(jsn, aud.id, @curr_user))

      # The following should only occur if the delayed job is successful; given this without a fail-out error it will still be updated. 
      # (TODO this may mean that the aud reference is not needed in the job, but later on that is probably a good identification point.)
      aud.update_attributes(audited_changes: "#{@num_products_loaded} products updated (or maintained)",associated_type:current_market.subdomain.to_s,comment:"#{User.find(current_user.id).email}") 
      # struct size differs????
      p "enqueued job for upload"

      # so this should really enqueue all these things below.



      # pass the datafile to the method with the csv file
      # jsn = ::Imports::SerializeProducts.get_json_data(params[:datafile],params[:curr_user]) # product stuff, row errors
      
      # TODO: the jsn business above it should also be handled by the worker in the delay

      ## TODO this bit should be replaced by performing the delayed job
      # unless jsn.include?("invalid")
      #   jsn[0]["products"].each do |p|
      #     ::Imports::ProductHelpers.create_product_from_hash(p,params[:curr_user])
      #     @num_products_loaded += 1
      #     # binding.pry
      #     if p.has_key?("Multiple Pack Sizes") && !p["Multiple Pack Sizes"].empty?
      #       @num_products_loaded += 1
      #     end
      #   end
      #   @errors = jsn[1]
      #   aud.update_attributes(audited_changes: "#{@num_products_loaded} products updated (or maintained)",associated_type:current_market.subdomain.to_s,comment:"#{User.find(current_user.id).email}") 
      # else
      #   @num_products_loaded = 0
      #   @errors = {"File"=>jsn}
      # end

    end
  end

end