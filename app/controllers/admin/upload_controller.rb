class Admin::UploadController < AdminController
	require 'rubyXL'

  def upload
  	uploaded = params[:datafile] # gets the xlsx data (or should) from form upload post req
  	filepath = Rails.root.join('tempfiles',uploaded.original_filename)
	  File.open(filepath, 'wb') do |file|
	  	file.write(uploaded.read) # writes that data to the open filestream in the tempfiles fldr
	  end
	end

  # def create 
  # 	if params
  # 		filepath = Rails.root.join('tempfiles', params[:datafile])['filename']
		#   IO.read(filepath)
		# end
  # end

  def index
  end

  def check
  	if params.has_key?(:datafile)
  		filepath_partial = params[:datafile].original_filename
  		filepath = './tempfiles/' + filepath_partial.to_s
  		# would be nice to audit contents here (like headers). right now let's run it as we were doing before.
			upload # call the upload method to write file to tempfiles
			profile = params[:profile] # todo: make sure profiles possible are generated and available in form from controller instead of typed into the template
			test = system( "./bin/import_products standard_template -p #{profile} -f '#{filepath}' 2> systemtesterrors1.yml") 
    	# then (maybe in another method) try to import it from the location and render errors + how many have been uploaded
    	return
		end
  end


end