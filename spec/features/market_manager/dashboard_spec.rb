require "spec_helper"

feature "a market manager viewing their dashboard" do
  let!(:user) { create(:user, :market_manager) }
  let!(:market) { user.managed_markets.first }

  before do
    market.update_attributes(subdomain: "ada")
    switch_to_subdomain(market.subdomain)

    sign_in_as user
  end

  describe "Current Sales tables" do
    before do
      create(:order, total_cost: 50, market: market, placed_at: DateTime.parse("2014-04-01 12:00:00"), order_number: "LO-14-TEST")
      create(:order, market: market)
      create(:order)

      visit dashboard_path
    end

    it "lists all sales for the currently managed market" do
      expect(page).to have_content("Current Sales")

      expect(Dom::Dashboard::CurrentSaleRow.all.count).to eq(2)
      order_row = Dom::Dashboard::CurrentSaleRow.first

      expect(order_row.order_number).to eq("LO-14-TEST")
      expect(order_row.placed_on).to eq("Apr 1, 2014")
      expect(order_row.total).to eq("$50.00")
      expect(order_row.delivery).to eq("Pending")
      expect(order_row.payment).to eq("Unpaid")
    end
  end

  describe "Products table" do
    let!(:organization) { create(:organization, name: "Super Farm!", markets: [market]) }
    let(:product) { create(:product, name: "Power Food", organization: organization) }

    before do
      create(:price, product: product, market: market, organization: organization, sale_price: 20)
      create(:lot, product: product, quantity: 123)
      create(:product)

      visit dashboard_path
    end

    it "lists all products in the managed market" do
      expect(page).to have_content("Products")

      expect(Dom::Dashboard::ProductRow.all.count).to eq(1)
      seller_row = Dom::Dashboard::ProductRow.first

      expect(seller_row.seller).to eq("Super Farm!")
      expect(seller_row.name).to eq("Power Food")
      expect(seller_row.pricing).to eq("$20.00")
      expect(seller_row.stock).to eq("123")
    end
  end
end