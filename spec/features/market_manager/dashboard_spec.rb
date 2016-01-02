require "spec_helper"

feature "a market manager viewing their dashboard" do
  let!(:user) { create(:user) }
  let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }
  let!(:market) { create(:market, :with_addresses, organizations: [buyer]) }
  let!(:market_manager) { create(:user, :market_manager, managed_markets: [market]) }

  let!(:delivery_schedule) { create(:delivery_schedule) }
  let!(:delivery)    { delivery_schedule.next_delivery }

  let!(:order_item1) { create(:order_item, unit_price: 10.00, quantity: 2) }
  let!(:order1) { create(:order, delivery: delivery, items: [order_item1], total_cost: 20.00, order_number: "LO-14-TEST-1", market: market) }

  Timecop.travel(DateTime.now + 1.day)

  let!(:order_item2) { create(:order_item, unit_price: 10.00, quantity: 1) }
  let!(:order2) { create(:order, delivery: delivery, items: [order_item2], total_cost: 10.00, order_number: "LO-14-TEST-2", market: market) }

  Timecop.return

  def login
    switch_to_subdomain(market.subdomain)
    sign_in_as(market_manager)
  end

  before do
    login
    visit dashboard_path
  end

  it "market_manager views dashboard - 7D", :js => true do

    expect(page).to have_selector("#totalSalesAmount", text: '$30')
    expect(page).to have_selector("#totalOrderCount", text: '2')
    expect(page).to have_selector("#averageSalesAmount", text: '$15')
  end

  it "market_manager views dashboard - 1D", :js => true do
    choose('1D')
    expect(page).to have_selector("#totalSalesAmount", text: '$20')
    expect(page).to have_selector("#totalOrderCount", text: '1')
    expect(page).to have_selector("#averageSalesAmount", text: '$10')
  end

end

=begin

  describe "Current Orders tables" do
    it "lists all sales for the currently managed market ordered by creation date" do
      product = create(:product, :sellable)

      order_item = create(:order_item, unit_price: 10.00, quantity: 2)
      create(:order, delivery: delivery, items: [order_item], total_cost: 20.00, order_number: "LO-14-TEST-2", market: market)

      order_item = create(:order_item, unit_price: 25.00, quantity: 2)
      create(:order, delivery: delivery, items: [order_item], total_cost: 50.00, market: market, placed_at: DateTime.parse("2014-04-01 12:00:00"), order_number: "LO-14-TEST")

      product.organization.markets << market

      create(:order, :with_items, delivery: delivery)

      visit dashboard_path

      expect(page).to have_content("Current Orders")

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

      expect(page).to have_content("Current Orders")
      expect(page).to have_content("No orders have yet been created")
    end
  end

  describe "Products table" do
    it "lists all products in the managed market by creation date" do
      organization = create(:organization, name: "Super Farm!", markets: [market])
      product = create(:product, name: "Power Food", organization: organization, unit: create(:unit, singular: "Capsule"))

      create(:price, product: product, market: market, organization: organization, sale_price: 20)
      create(:lot, product: product, quantity: 123)
      create(:product, :sellable, name: "Last Thing", organization: organization, created_at: 1.day.ago)
      create(:product)

      visit dashboard_path
      expect(page).to have_content("Products")

      expect(Dom::Dashboard::ProductRow.all.count).to eq(2)
      seller_row = Dom::Dashboard::ProductRow.first

      expect(seller_row.seller).to eq("Super Farm!")
      expect(seller_row.name).to eq("Power Food (Capsule)")
      expect(seller_row.pricing).to have_content("$20.00")
      expect(seller_row.stock).to have_content("123")
    end

    it "displays a message if there are no products" do
      visit dashboard_path

      expect(page).to have_content("Products")
      expect(page).to have_content("No products have yet been created")
    end
  end
=end