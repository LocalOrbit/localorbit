module ProductUpload
  include Imports
	class ProductUploadJob  < Struct.new(:jsn, :upload_audit_id, :curr_user, :curr_market) # pass in the datafile like is done right now in uploadcontroller, i.e.

		def enqueue(job)
		end

		def success(job)
      UploadMailer.delay(priority: 30).upload_success(User.find(curr_user).email, @num_products_loaded, @errors)
    end

		def error(job, exception)
      UploadMailer.delay(priority: 30).upload_fail(User.find(curr_user).email, @errors)
		end

		def failure(job)
      UploadMailer.delay(priority: 30).upload_fail(User.find(curr_user).email, @errors)
    end

    def perform
    	# iterate over the json data and create / update objects
    	aud = Audit.find(upload_audit_id)
      @num_products_loaded = 0
    	unless jsn.include?("invalid")
        jsn[0]["products"].each do |p|
          ::Imports::ProductHelpers.create_product_from_hash(p, curr_user, curr_market)
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
      end
    end
	end
end