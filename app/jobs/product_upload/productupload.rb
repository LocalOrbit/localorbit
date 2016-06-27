module ProductUpload
	class ProcessProductUploadJob  < Struct.new(:upload_audit_id) # hmm
		
		def enqueue(job)
			job.delayed_reference_id = upload_audit_id
			job.delayed_reference_type = 'ProductUpload' # TODO ??
			job.save!
		end

		def success(job)
			update_status('success')
		end

		# TODO really necessary?
		def error(job, exception)
			update_status("There was an error, please try again")
			# Send any other alert? Where should this go? TODO
		end

		def failure(job)
      update_status('failure')
    end

    # helper methods to process things go here

    def perform
    	# this is the method that should so something
    	# TODO maybe others here shoudl change too since this job isn't just processing stuff

    	# this is where the actual uploading should go in the controller n stuff
    end


		private

		def check_and_update_status
			upload = Audit.find(upload_audit_id)
			# TODO raise error here, or no reason to for this?
			raise StandardError.new("Your upload is not complete") unless upload.status == 'new' # is new a default thing
			upload.status = 'processing'
			upload.save!
		end

		def update_status(status)
			upload = Audit.find(upload_audit_id)
			upload.status = status
			upload.save!
    end

	end
end