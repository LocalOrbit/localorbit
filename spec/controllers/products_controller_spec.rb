require "spec_helper"

describe ProductsController do
  let(:org1) { create(:organization) }
  let(:org2) { create(:organization) }
  let(:product1) { create(:product, :sellable, organization: org2, name: 'apples') }
  let(:product2) { create(:product, :sellable, organization: org2, name: 'beer') }
  let(:market) { create(:market, organizations: [org1, org2]) }
  let(:user) { create(:user, :market_manager, organizations: [org1]) }
  let!(:location) { create(:location, organization: org1) }

  describe "/index" do
    context "on a market subdomain" do
      before do
        switch_to_subdomain market.subdomain
      end

      it "redirects to new address page if you don't have any locations" do
        location.soft_delete
        sign_in user
        get :index

        expect(response).to redirect_to(new_admin_organization_location_path(org1))
      end
    end

    context "on the main domain" do
      let(:admin) { create(:user, :admin) }
      before do
        switch_to_main_domain
        sign_in admin
      end

      it "requires a market" do
        get :index
        expect(response).to be_success
        expect(response).to render_template("select_market")
      end
    end
  end

  describe "/search" do
    let(:user) { create(:user, :market_manager) }
    let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }
    let!(:seller) { create(:organization, :seller, :single_location, name: 'First Seller') }
    let!(:second_seller) { create(:organization, :seller, :single_location, name: 'Second Seller') }

    let(:market) { create(:market, :with_addresses, organizations: [buyer, seller, second_seller]) }
    let!(:delivery) { create(:delivery_schedule, market: market) }

    # Products
    let!(:bananas) { create(:product, name: "Bananas", organization: seller, delivery_schedules: [delivery]) }
    let!(:bananas_lot) { create(:lot, product: bananas) }
    let!(:bananas_price_buyer_base) do
      create(:price, :past_price, market: market, product: bananas, min_quantity: 1, organization: buyer)
    end

    let!(:bananas2) { create(:product, name: "Bananas", organization: second_seller, delivery_schedules: [delivery]) }
    let!(:bananas2_lot) { create(:lot, product: bananas2) }
    let!(:bananas2_price_buyer_base) do
      create(:price, :past_price, market: market, product: bananas2, min_quantity: 1, organization: buyer)
    end

    let!(:kale) { create(:product, name: "Kale", organization: seller, delivery_schedules: [delivery]) }
    let!(:kale_lot) { create(:lot, product: kale) }
    let!(:kale_price_buyer_base) do
      create(:price, :past_price, market: market, product: kale, min_quantity: 1)
      create(:price, :past_price, market: market, product: kale, min_quantity: 10, sale_price: 1.75)
    end


    before do
      switch_to_subdomain market.subdomain
      sign_in user

      @banana_result = {"id"=>bananas.id, "name"=>"Bananas", "second_level_category_name"=>"Apples", "seller_name"=>"First Seller", "pricing"=>"$3.00 for 1+", "unit_with_description"=>"boxes"}
      @banana2_result = {"id"=>bananas2.id, "name"=>"Bananas", "second_level_category_name"=>"Apples", "seller_name"=>"Second Seller", "pricing"=>"$3.00 for 1+", "unit_with_description"=>"boxes"}
      @kale_result = {"id"=>kale.id, "name"=>"Kale", "second_level_category_name"=>"Apples", "seller_name"=>"First Seller", "pricing"=>"$3.00 for 1+, $1.75 for 10+", "unit_with_description"=>"boxes"}
    end

    def search(query)
      get :search, q: query
      JSON.parse(response.body)["products"]
    end

    it "requires at least four characters" do
      expect(search("ban")).to eq([])
    end

    it "returns empty arrays when no match found" do
      expect(search("lembas")).to eq([])
    end

    it "searches by product name" do
      expect(search("bana")).to eq([@banana_result, @banana2_result])
      expect(search("kale")).to eq([@kale_result])
    end

    it "searches by seller name" do
      expect(search("First Seller")).to eq([@banana_result, @kale_result])
      expect(search("Second")).to eq([@banana2_result])
    end

    it "searches by second category name" do
      expect(search("Apple")).to eq([@banana_result, @banana2_result, @kale_result])
    end

    it "searches by arbitrary case insensitive combinations of product name, seller name, and second category name" do
      expect(search("FirSt ban")).to eq([@banana_result])
      expect(search("ban seco")).to eq([@banana2_result])
      expect(search("first APPLE kaL")).to eq([@kale_result])
    end

    it "only shows products that can be sold on the market" do
      no_prices = create(:product, name: "Bad apples", organization: seller, delivery_schedules: [delivery])
      create(:lot, product: no_prices)
      no_inventory = create(:product, name: "Bad apples", organization: seller, delivery_schedules: [delivery])
      expect(search("bad ap")).to eq []
    end
  end
end
