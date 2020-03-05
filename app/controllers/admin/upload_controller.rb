class Admin::UploadController < AdminController
	require 'rubyXL'
  require 'open3'
  # include API::V2
  include Imports

  def index
    @plan = current_market.organization.plan.name
    @sd = current_market.subdomain
    @current_mkt_id = current_market.id #TODO maybe useful
    # code for mapping organization and ensuring sign-in authenticated upload
    @org_ids = current_user.organizations.map(&:id)
    @curr_user = current_user.id # to pass along, will find user by id in get_org method
  end

  def download
    send_file(
      "#{Rails.root}/app/assets/download_files/LocalOrbit_product_upload_template.csv",
      filename: "LocalOrbit_product_upload_template.csv",
      type: "application/text"
    )
  end

  def export_products
    @products = current_user.managed_products.includes(:unit, prices:[:market]).order("organizations.name, products.name")
    respond_to do |format|
      format.html
      format.csv do
        if ENV["USE_UPLOAD_QUEUE"] == "true"
          Delayed::Job.enqueue ::CSVExport::CSVImportProductExportJob.new(current_user, current_market.subdomain, @products.map(&:id)), priority: 30
          flash[:notice] = "Please check your email for export results."
          redirect_to admin_upload_path
        else
          @filename = 'products.csv'
          @products = @products
        end
      end
    end
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
      if ENV['USE_UPLOAD_QUEUE'] == "true"
        Delayed::Job.enqueue ::ProductUpload::ProductUploadJob.new(jsn, aud.id, params[:curr_user], current_market), priority: 30
        render :upload_delayed
      else
        #pass the datafile to the method with the csv file
        # TODO: the jsn business above it should also be handled by the worker in the delay
        unless jsn.include?("invalid")
         jsn[0]["products"].each do |p|
           ::Imports::ProductHelpers.create_product_from_hash(p,params[:curr_user], current_market)
           @num_products_loaded += 1
           if p.has_key?("Multiple Pack Sizes") && !p["Multiple Pack Sizes"].empty?
             @num_products_loaded += 1
           end
         end
         @errors = jsn[1]
         aud.update_attributes(audited_changes: "#{@num_products_loaded} products updated (or maintained)",associated_type:current_market.subdomain.to_s,comment:"#{User.find(current_user.id).email}")
        else
         @num_products_loaded = 0
         @errors = {"File"=>jsn}
        end
        render :upload
      end
    end
  end

end