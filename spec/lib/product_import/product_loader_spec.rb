require 'spec_helper'

describe ProductImport::ProductLoader do
	let!(:seller_org) { create(:organization, :seller) }
	let!(:cat1) {create(:category)}
	let!(:unit1) {create(:unit)}
	let!(:upsert_time) { Time.now }

	it "should create products with prices and lots" do
		data = [{
				"category_id" => cat1.id,
				"organization_id" => seller_org.id,
				"unit_id" => unit1.id,
				"name" => "BrandNewProductTest",
				"price" => "25.24",
				"product_code" => "abc1234",
				"short_description" => "Test short",
				"long_description" => "Test long",
				"contrived_key" => "anactualsha1",
				"source_data" => {"foo"=>"bar"}
			}]

		res = subject.upsert_products(data,batch_updated_at:upsert_time)
		first_product = res.first

		expect(res.length).to eq(1)
		expect(first_product).to be_a(Product)
		expect(first_product.name).to eq("BrandNewProductTest")
		expect(first_product).to be_persisted
	end


end