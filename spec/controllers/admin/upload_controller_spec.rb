require 'spec_helper'

describe Admin::UploadController do

	let!(:market)   { create(:market, subdomain:"birite", id:130) } # will this work with the test db?
	let!(:seller_org) {create(:organization, name:"bi-rite") }

	it "exists as a layer on top of the product import" do
		expect(subject).to be 
	end

end