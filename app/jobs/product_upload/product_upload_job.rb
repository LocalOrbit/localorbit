module ProductUpload
  include Imports
	class ProductUploadJob  < Struct.new(:jsn, :upload_audit_id, :curr_user) # pass in the datafile like is done right now in uploadcontroller, i.e.
		# :Imports::SerializeProducts.get_json_data(params[:datafile],params[:curr_user])
		
		# def enqueue(job)
		# 	job.delayed_reference_id = upload_audit_id
		# 	job.delayed_reference_type = 'ProductUpload' # ?
		# 	job.save!
		# end

		def success(job)
		 	#update_status('success')
      UserMailer.delay.upload_success(:curr_user)
    end

		# # TODO necessary?
		# def error(job, exception)
		# 	update_status("There was an error, please try again")
		# 	# Send any other alert? ? TODO
		# end

		def failure(job)
       #update_status('failure')
       UserMailer.delay.upload_fail(:curr_user)
    end

    # helper methods to process things here ? can get them from inclusions??

    def perform
    	# iterate over the json data and create / update objects
    	aud = Audit.find(upload_audit_id)
    	unless jsn.include?("invalid")
        jsn[0]["products"].each do |p|
          ::Imports::ProductHelpers.create_product_from_hash(p, :curr_user)
          @num_products_loaded += 1 # how does this get added to, also? different scope
          if p.has_key?("Multiple Pack Sizes") && !p["Multiple Pack Sizes"].empty?
            @num_products_loaded += 1
          end
        end
        @errors = jsn[1]
        aud.update_attributes(audited_changes: "#{@num_products_loaded} products updated (or maintained)",associated_type:current_market.subdomain.to_s,comment:"#{User.find(current_user.id).email}")
      else
        @num_products_loaded = 0
        @errors = {"File"=>jsn} # how does errors get to the view this way?
        raise StandardError.new("Failed to process video with id: #{video.id}") unless video.process?
      end
    end


		# private

		# def check_and_update_status
		# 	upload = Audit.find(upload_audit_id) # this is probably not actually what to do though
		# 	# check the audit for it being completed or something

		# 	raise StandardError.new("Your upload is not complete") unless upload.status == 'new' # is new a default thing or should this happen elsewhere with update_status
		# 	job.status = 'processing'
		# 	job.save!
		# end

		# def update_status(status)
		# 	job = Audit.find(upload_audit_id)
		# 	job.status = status
		# 	job.save!
  #   end

	end
end