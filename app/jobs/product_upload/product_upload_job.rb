module ProductUpload
  include Imports
	class ProductUploadJob  < Struct.new(:jsn, :upload_audit_id, :curr_user, :curr_market) # pass in the datafile like is done right now in uploadcontroller, i.e.

		def enqueue(job)
		end

		def success(job)
      UploadMailer.delay.upload_success(User.find(curr_user).email, @num_products_loaded, @errors)
    end

		def error(job, exception)
      UploadMailer.delay.upload_fail(User.find(curr_user).email, @errors)
		end

		def failure(job)
      UploadMailer.delay.upload_fail(User.find(curr_user).email, @errors)
    end

    def perform
    	# iterate over the json data and create / update objects
    	aud = Audit.find(upload_audit_id)
      @num_products_loaded = 0
    	unless jsn.include?("invalid")
        jsn[0]["products"].each do |p|
          ::Imports::ProductHelpers.create_product_from_hash(p, curr_user)
          @num_products_loaded += 1 # how does this get added to, also? different scope
          if p.has_key?("Multiple Pack Sizes") && !p["Multiple Pack Sizes"].empty?
            #@num_products_loaded += 1
          end
        end
        @errors = jsn[1]
        aud.update_attributes(audited_changes: "#{@num_products_loaded} products updated (or maintained)",associated_type:curr_market.subdomain.to_s,comment:"#{User.find(curr_user).email}")
      else
        @num_products_loaded = 0
        @errors = {"File"=>jsn}
        raise StandardError.new("Failed to process file")
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