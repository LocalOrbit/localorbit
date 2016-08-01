module Jobs
	module ProductUpload
		include Imports
		class ProductUploadJob
			def initialize(jsn, upload_audit_id, curr_user) 
				@jsn = jsn
				@upload_audit_id = upload_audit_id
				@curr_user = curr_user
			end
			# pass in the datafile like is done right now in uploadcontroller, i.e.
			# :Imports::SerializeProducts.get_json_data(params[:datafile],params[:curr_user])
			
			# def enqueue(job)
			# 	job.delayed_reference_id = upload_audit_id
			# 	job.delayed_reference_type = 'ProductUpload' # ?
			# 	job.save!
			# end

			# def success(job)
			# 	update_status('success')
			# end

			# # TODO necessary?
			# def error(job, exception)
			# 	update_status("There was an error, please try again")
			# 	# Send any other alert? ? TODO
			# end

			# def failure(job)
	  #     update_status('failure')
	  #   end

	    # helper methods to process things here ? can get them from inclusions??

		    def perform
		    	p "hi this is nothing"
		    	@num_products_loaded = 0
		    	# iterate over the json data and create / update objects
		    	binding.pry
		    	aud = Audit.find(@upload_audit_id)
		    	unless @jsn.include?("invalid")
		        @jsn[0]["products"].each do |p|
		          ::Imports::ProductHelpers.create_product_from_hash(p,@curr_user)
		          @num_products_loaded += 1 # how does this get added to, also? different scope
		          if p.has_key?("Multiple Pack Sizes") && !p["Multiple Pack Sizes"].empty?
		            @num_products_loaded += 1
		          end
		        end
		        @errors = @jsn[1]
		        # aud.update_attributes(audited_changes: "#{@num_products_loaded} products updated (or maintained)",associated_type:current_market.subdomain.to_s,comment:"#{User.find(current_user.id).email}") 


		        # TODO put together messaging for the alert to be sent

		        # TODO send email/message here when it is complete


		        

		      # THE BEGINNING OF THE IF -- for overall errors -- IS NO LONGER HERE
		      # else
		      #   @num_products_loaded = 0
		      #   @errors = {"File"=>jsn} # how does errors get to the view this way? Without this here in the jobs file, errors parsing ideally gets a little refactored. For upload given recent developments... well, here's some duct tape, Jun16. Sorry.
		      # end
		    	
		    end
		    # TODO: other functionality of jobs good here?
		    # TODO: Need to send information from the job back to the other view. Could do so in the audit but the db is ideally not used for that kind of transactional info, expensive and annoying, ajax or st is probably better.


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
	    	end # why

		end
	end
end
