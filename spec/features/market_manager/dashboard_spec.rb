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
    it "lists all sales for the currently managed market ordered by creation date" do
      order1 = create(:order, order_number: "LO-14-TEST-2", market: market)
      order2 = create(:order, total_cost: 50, market: market, placed_at: DateTime.parse("2014-04-01 12:00:00"), order_number: "LO-14-TEST")
      product = create(:product, :sellable)
      product.organization.markets << market

      create(:order_item, product: product, order: order1, delivery_status: "pending")
      create(:order_item, product: product, order: order2, delivery_status: "pending")
      create(:order)

      visit dashboard_path

      expect(page).to have_content("Current Sales")

      expect(Dom::Dashboard::OrderRow.all.count).to eq(2)
      order_row = Dom::Dashboard::OrderRow.first

      expect(order_row.order_number).to eq("LO-14-TEST")
      expect(order_row.placed_on).to eq("Apr 1, 2014")
      expect(order_row.total).to eq("$50.00")
      expect(order_row.delivery).to eq("Pending")
      expect(order_row.payment).to eq("Unpaid")

      expect(Dom::Dashboard::OrderRow.all.last.order_number).to eq("LO-14-TEST-2")
    end

    it "displays a message if there are no orders" do
      visit dashboard_path

      expect(page).to have_content("Current Sales")
      expect(page).to have_content("No orders have yet been created")
    end
  end

  describe "Products table" do
    it "lists all products in the managed market by creation date" do
      organization = create(:organization, name: "Super Farm!", markets: [market])
      product = create(:product, name: "Power Food", organization: organization)

      create(:price, product: product, market: market, organization: organization, sale_price: 20)
      create(:lot, product: product, quantity: 123)
      create(:product, :sellable, name: "Last Thing", organization: organization, created_at: 1.day.ago)
      create(:product)

      visit dashboard_path
      expect(page).to have_content("Products")

      expect(Dom::Dashboard::ProductRow.all.count).to eq(2)
      seller_row = Dom::Dashboard::ProductRow.first

      expect(seller_row.seller).to eq("Super Farm!")
      expect(seller_row.name).to eq("Power Food")
      expect(seller_row.pricing).to eq("$20.00")
      expect(seller_row.stock).to eq("123")
    end

    it "displays a message if there are no products" do
      visit dashboard_path

      expect(page).to have_content("Products")
      expect(page).to have_content("No products have yet been created")
    end
  end
end