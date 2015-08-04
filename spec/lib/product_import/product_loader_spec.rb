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
				"price" => "25.24", # string or number
				"product_code" => "abc1234",
				"short_description" => "Test short",
				"long_description" => "Test long",
				"contrived_key" => "anactualsha1",
				"source_data" => {"foo"=>"bar"}
			}]

		res = subject.upsert_products(data,batch_updated_at:upsert_time)
		first_product = res.first
		price_prod = first_product.prices.first
		lot_prod = first_product.lots.first
		external_product = first_product.external_product # TODO create association

		expect(res.length).to eq(1)

		expect(first_product).to be_a(Product)
		expect(first_product.name).to eq("BrandNewProductTest")
		expect(first_product.organization_id).to eq(seller_org.id)
		expect(first_product).to be_persisted

		expect(price_prod.sale_price).to eq(BigDecimal.new("25.24"))
		expect(price_prod.min_quantity).to eq(1)
		expect(price_prod).to be_persisted

		expect(lot_prod.quantity).to eq(999999)
		expect(lot_prod).to be_persisted

		expect(external_product.contrived_key).to eq("anactualsha1")
		expect(external_product.organization_id).to eq(seller_org.id)
		expect(external_product.source_data).to eq({"foo"=>"bar"})
		expect(external_product).to be_persisted
		
	end

	it "updates products properly" do
		original_ep = create :external_product, contrived_key: "anactualsha1"

		data = [{
				"category_id" => cat1.id,
				"organization_id" => original_ep.organization_id,
				"unit_id" => unit1.id,
				"name" => "BrandNewProductTest",
				"price" => "25.24", # string or number
				"product_code" => "abc1234",
				"short_description" => "Test short",
				"long_description" => "Test long",
				"contrived_key" => "anactualsha1",
				"source_data" => {"foo"=>"bar"}
			}]

		res = subject.upsert_products(data,batch_updated_at:upsert_time)
		first_product = res.first
		price_prod = first_product.prices.first
		lot_prod = first_product.lots.first
		external_product = first_product.external_product # TODO create association

		expect(res.length).to eq(1)

		expect(first_product).to be_a(Product)
		expect(first_product.id).to eq(original_ep.product.id)
		expect(first_product.name).to eq("BrandNewProductTest")
		expect(first_product.organization_id).to eq(original_ep.organization_id)
		expect(first_product).to be_persisted

		expect(price_prod.sale_price).to eq(BigDecimal.new("25.24"))
		expect(price_prod.min_quantity).to eq(1)
		expect(price_prod).to be_persisted
		expect(price_prod.id).to eq(original_ep.product.prices.first.id)

		expect(lot_prod.quantity).to eq(999999)
		expect(lot_prod.id).to eq(original_ep.product.lots.first.id)
		expect(lot_prod).to be_persisted

		expect(external_product.contrived_key).to eq("anactualsha1")
		expect(external_product.organization_id).to eq(original_ep.organization_id)
		expect(external_product.source_data).to eq({"foo"=>"bar"})
		expect(external_product).to be_persisted

	end

	it "should create a price and lot for an existing product without them" do
		product = create :product

		expect(product.prices.length).to eq(0) # check to make sure no prices
		expect(product.lots.length).to eq(0) # check to make sure no lots

		original_ep = create :external_product, contrived_key: "anactualsha1", product:product
		data = [{
				"category_id" => cat1.id,
				"organization_id" => original_ep.organization_id,
				"unit_id" => unit1.id,
				"name" => "BrandNewProductTest",
				"price" => "25.24", # string or number
				"product_code" => "abc1234",
				"short_description" => "Test short",
				"long_description" => "Test long",
				"contrived_key" => "anactualsha1",
				"source_data" => {"foo"=>"bar"}
			}]

		res = subject.upsert_products(data,batch_updated_at:upsert_time)
		first_product = res.first
		price_prod = first_product.prices.first
		lot_prod = first_product.lots.first
		external_product = first_product.external_product # TODO create association

		expect(res.length).to eq(1)

		expect(price_prod.sale_price).to eq(BigDecimal.new("25.24"))
		expect(price_prod.min_quantity).to eq(1)
		expect(price_prod).to be_persisted

		expect(lot_prod.quantity).to eq(999999)
		expect(lot_prod).to be_persisted

	end


end