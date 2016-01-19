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

		it "returns a product list when identified by category" do
		end

	end

	describe "POST /api/v2/add-product" do

		it "posts one product correctly with 201 response" do
		end

	end

	describe "POST /api/v2/add-products" do

		it "correctly posts products when properly formatted JSON data file is posted" do
		end

	end


end