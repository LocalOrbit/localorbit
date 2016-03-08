require "spec_helper"

describe API::V2::Products, :type => :request do

let!(:org) { create(:organization, name: "Organization 1") }
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

############

	describe "POST /api/v2/add-product" do

		it "posts one product correctly with 201 response" do # todo market name problem - in controller
			post "api/v2/products/add-product", {name:"Super Unusual Name",organization_name:"Organization 1",price:2.34,unit:"box",category:"Fruits",code:"hmmm-abc",short_description:"short",long_description:"GOES ON FOREVER long long long",unit_description:"unit description with new unit same product"}.to_json, {"Content-Type"=>"application/json"}

			expect(response.status).to eq(201)
			expect(JSON.parse(response.body)).to eq({"result" => "product successfully created"})
		end

		it "returns a bad request response on malformed request data (no product name)" do
			post "api/v2/products/add-product", {organization_name:"Organization 1",price:2.34,unit:"box",category:"Fruits",code:"hmmm-abc",short_description:"short",long_description:"GOES ON FOREVER long long long",unit_description:"unit description with new unit same product"}.to_json, {"Content-Type"=>"application/json"}

			expect(response.status).not_to eq(201)
			expect(response.status).to eq(400)
		end

		it "returns a bad request response on malformed request data (no org name)" do
			post "api/v2/products/add-product", {name:"Super Unusual Name",price:2.34,unit:"box",category:"Fruits",code:"hmmm-abc",short_description:"short",long_description:"GOES ON FOREVER long long long",unit_description:"unit description with new unit same product"}.to_json, {"Content-Type"=>"application/json"}

			expect(response.status).not_to eq(201)
			expect(response.status).to eq(400)
		end

		# TODO: test for mkt name, org name, behavior when route is adequately supported for markets (and orgs)

	end

	describe "POST /api/v2/add-products" do

		it "correctly posts products when properly formatted JSON data file is posted" do
			post "api/v2/products/add-products", {"products_total"=>2,"products"=> [{"Organization"=>"Boettcher Farm","Category"=>"Fruits","Product Name"=>"Test Product 1","Code"=>"abcdef-code1","Short Description"=>"look how short","Long Description"=>"look how long","Unit"=>"Case","Unit Description"=>"5 pound boxcase of something","Price"=>2.41,"Multiple Pack Sizes"=>"N"},{"Organization"=>"Boettcher Farm","Category"=>"Fruits","Product Name"=>"Test Product 33","Code"=>"abcdef-code3","Short Description"=>"look how short here is another thing","Long Description"=>"look how long","Unit"=>"Box","Unit Description"=>"5 pound boxcase more like box of something","Price"=>2.45,"Multiple Pack Sizes"=>"N"}]}
		end

	end


end