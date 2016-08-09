class Admin::UploadController < AdminController
	require 'rubyXL'
  require "#{Rails.root}/lib/jobs/productupload.rb" 
  include Imports
  include Jobs

  # NOTE (TODO):
  # This look like a good refactor template for this messy mess that works 06-16: http://nlopez.io/using-delayed_job-with-class-methods/ plus (perhaps) a couple gems.

  def index
    @plan = current_market.organization.plan.name # check if LocalEyes plan on market # "LocalEyes"
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
      aud = Audit.create!(user_id:current_user.id,action:"Product upload") # the id of this audit is what could trigger the job. For now, keep track of it.
      aud.update_attributes(associated_type:current_market.subdomain.to_s,comment:"#{User.find(current_user.id).email}") # incomplete at this juncture because no comment with load, so that's OK
      jsn = ::Imports::SerializeProducts.get_json_data(params[:datafile],params[:curr_user]) # Does this take too much time?
      @curr_user = params[:curr_user] # to pass along
      Delayed::Job.enqueue(::Jobs::ProductUpload::ProductUploadJob.new(jsn, aud.id, @curr_user))
      # Enqueued, after which success an email should be sent
      # See lib/jobs/productupload.rb
    end
  end

end