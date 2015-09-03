module ProductImport

	def upload_file(file_name)
		file_path = Rails.root.join('tempfiles', "#{file_name}") # how are we dealing with file names, let's assume they include the extension
		# deal with file/file format?
		exported_file = 'a' # fill in the actual file data
		# audit file and return a message to display if bad

		# Save file to disk, write binary
		File.open(file_path, 'wb') do |file|
			if audit_file(exported_file)
		  	file << exported_file 
		  else
		  	# display message "Badly formatted file. Correct file type(.XLSX)? Are the headers correct? Are all the columns complete?"
		  end
		end
	end

	def audit_file(exported_file)
		# open the file from wherever 

		# check the headers

		# check that there are no blank strings in Supplier Product Code column

		# in either case exit with error
		if cases_true
			return true
		else
			return false
		end
	end

end