module Jobs
	module ProductUpload
		include Imports
		class ProductUploadJob
			def initialize(jsn, upload_audit_id, curr_user) 
				@jsn = jsn
				@upload_audit_id = upload_audit_id
				@curr_user = curr_user
			end
			
			# def enqueue(job)
			# 	job.delayed_reference_id = upload_audit_id
			# 	job.delayed_reference_type = 'ProductUpload' # ?
			# 	job.save!
			# end

			# def success(job)
			# 	update_status('success')
			# end

		    def perform
		    	@num_products_loaded = 0
		    	# iterate over the json data and create / update objects
		    	aud = Audit.find(@upload_audit_id)
		    	unless @jsn.include?("invalid")
		        @jsn[0]["products"].each do |p|
		          ::Imports::ProductHelpers.create_product_from_hash(p,@curr_user)
		          @num_products_loaded += 1 # This is info that needs to go in the alert
		          if p.has_key?("Multiple Pack Sizes") && !p["Multiple Pack Sizes"].empty?
		            @num_products_loaded += 1
		          end
		        end
		        @errors = @jsn[1] # This is info that needs to go in the alert.



		        # aud.update_attributes(audited_changes: "#{@num_products_loaded} products updated (or maintained)",associated_type:current_market.subdomain.to_s,comment:"#{User.find(current_user.id).email}") ## TODO: can't access this here? May be able to with rescoping.


		        # TODO put together messaging for the alert to be sent (see upload-html-for-alert-plan file, which is the same as the old version of upload.html before delayedjob implementation here)
		        @alert_string = ""


		        # TODO send email/message here when it is complete. Put here, at completion of job.
		    	
		    end
		    # TODO: Any other functionality here? Not needed now. (Jun16)
			
	    	end 
		end
	end
end
