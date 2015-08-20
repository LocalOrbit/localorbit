class Admin::UploadController < AdminController
	require 'rubyXL'
  include ProductImport

  def upload
  	uploaded = params[:datafile] # gets the xlsx data (or should) from form upload post req

  	filepath = Rails.root.join('tempfiles',uploaded.original_filename)
	  File.open(filepath, 'wb') do |file|
	  	file.write(uploaded.read) # writes that data to the open filestream in the tempfiles fldr
	  end
	  # ft = IO.read(filepath)
	  # ft.readlines.each do|lm| puts lm end

	  #redirect_to "/upload#create", notice: "Imported products successfully."
	end

  def create
  	if params
  		filepath = Rails.root.join('tempfiles', params[:datafile])['filename']
	  	#workbook = RubyXL::Parser.parse(filepath)
		  IO.read(filepath)
		end
  end

  def index
  end

  def check
  	if params.has_key?(:datafile)
  		filepath_partial = params[:datafile].original_filename
  		filepath = './tempfiles' + filepath_partial.to_s
  		# would be nice to audit contents here, a la
			#contents = params[:datafile].read.split("\r\n")
			#render :text => contents
			# BUT need to parse xlsx files for that, and meh. right now let's run it as is ,
			#  "try to import" using the same old process, and
			#  spit out the errors pretty and have that be that.
			upload
			#file_contents = params[:datafile]
			profile = params[:profile] # todo: make sure profiles possible are generated and available in form from controller instead of typed into the template

			# k, now go access the stuff we saved 

			value = %x( ./bin/import_products standard_template -p #{profile} -f #{filepath} 2> veryuniquefile_errors.yml)
			# todo: make sure this is properly running the right file
			# todo: capture the errors in the yml format and make em pretty so you can scroll and see em, maybe iframe maybe not



    	# now want to open it and look at it for audit

    	# then (maybe in another method) try to import it from the location and render errors + how many have been uploaded!
    	return
		end
  end

 #  def create
 #  	uploaded = params[:upload][:file]
	#   File.open(Rails.root.join('tempfiles',uploaded.original_filename), 'wb') do |fl|
	#   	fl.write(uploaded.read)
	#   end
	#   puts "Uploaded products successfully"
	# end

  # ProductImport::UploadFile
  # def create
  # 	puts "NOTICEABLESTRING"
  #   #@upload = Upload.new
  #   @file = Upload.new
  #   file_path = Rails.root.join('tempfiles', "#{file_name}") # how are we dealing with file names, let's assume they include the extension
		# # deal with file/file format? any need?
		
		# # Save file-- open file path, get file from form...
		# File.open(file_path, 'wb') do |fl|
		# 	exported_file = IO.readlines(file)# file that you get from form import whatever whatever ?? # exports in lines -- format ok?
		# 	if audit_file(exported_file)
		#   	fl << exported_file 
		#   else
		#   	# actually send this msg to view ntbd
		#   	puts "Badly formatted file. Is it the correct file type? Are the headers correct? Are the columns complete?"
		#   	# display message "Badly formatted file. Correct file type(.XLSX)? Are the headers correct? Are all the columns complete?"
		#   end
		# end
  # end

  # def create
  #   @upload = Upload.new(params[:file])
  #   if @upload.save
  #     redirect_to "/upload", notice: "Imported products successfully."
  #   else
  #     render :new
  #   end
  # end



end