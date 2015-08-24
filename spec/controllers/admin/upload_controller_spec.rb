require 'spec_helper'

describe Admin::UploadController do

	let!(:market)   { create(:market, subdomain:"birite", id:130) } # will this work with the test db?
	let!(:seller_org) {create(:organization, name:"bi-rite") }

	it "accepts a file and saves it to tempfiles directory" do
		test_filename = "admin_upload_template_withPC_good.xlsx"
		test_file = test_file(test_filename)

		pending("Incomplete test")
		#expect(`ls #{Rails.root + "tempfiles"}`.split("\n")).to include(test_filename) # hmm
	
		it "handles upload messages" do
			pending("Incomplete test")
			# go to path 

			# check for "No errors! Hooray!"
		end

		it "renders errors to user for bad headers" do
			pending("Incomplete test")
			# upload a file with bad headers
			# expect to see the Bad File error on loaded page

		end

		it "renders correct errors to user for missing fields" do
			pending("Incomplete test")
			# upload a bad file with known errors
			# expect to see the errors on the loaded page

		end

	end

	def test_file(fname)
    path = Rails.root + "spec/lib/product_import/test_data" + fname
    raise ArgumentError, "Unknown test file #{fname}" unless path.file?
  	path
  end
end