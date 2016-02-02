require "spec_helper"

describe API::V2::Products, :type => :request do

let!(:product1) { create(:product, name:"Test Product 1") }
let!(:product2) { create(:product, name:"Test Product 2") }

	describe "GET /api/v2/products" do
		it "returns a product when identified by name with correct info" do
			get "api/v2/products?id=2"
			expect(response.status).to eq(200)
			expect(JSON.parse(response.body)["products"][0]["name"]).to eq("Test Product 1")
			expect(JSON.parse(response.body)["products"][0]["category_id"]).to eq(4)
		end

		it "returns a product list when get product identified by category" do
			get "api/v2/products?category=category+1"
			expect(response.status).to eq(200)
			expect(JSON.parse(response.body)["products"].length).to eq(2)
		end

	end

	## TODO: Testing in Postman, etc -  butcan you test in rspec this way? 
	## JavaScript tests with jquery 

############

	# describe "POST /api/v2/add-product" do

	# 	it "posts one product correctly with 201 response" do # todo market name problem - in controller
	# 		post "api/v2/products/add-product"

	# 		#{}?organization_name=Boettcher+Farm&category=Fruits&code=hmmm-abc&name=Very+Unusual+Name&short_description=short&price=2.34&long_description=GOES+ON+FOREVER+long+long+long&unit=Case&unit_description=unit+description+with+new+unit+same+product"

	# 		#, {name:"Very Unusual Name",organization_name:"Boettcher Farm",price:2.34,unit:"Case",category:"Fruits",code:"hmmm-abc",short_description:"short",long_description:"GOES ON FOREVER long long long",unit_description:"unit description with new unit same product"}.to_json, {"Content-Type"=>"application/json"}
	# 		#expect(response.status).to eq(201)
	# 		#binding.pry
	# 		expect(JSON.parse(response.body)).to eq("hi")
	# 	end

	# 	it "returns a bad request response on malformed request data (no product name)" do
	# 		# remove product name and make sure it gives error
	# 	end

	# 	it "returns a bad request response on malformed request data (no org name)" do
	# 		# same for correct single product request with no org name
	# 	end

	# 	# TODO: test for mkt name behavior when route is adequately supported for markets

	# end

	# describe "POST /api/v2/add-products" do

	# 	it "correctly posts products when properly formatted JSON data file is posted" do
	# 	end

	# end


end