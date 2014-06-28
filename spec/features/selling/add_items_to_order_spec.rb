require 'spec_helper'

describe "Adding items to an order" do
  let!(:market)         { create(:market, :with_addresses, market_seller_fee: 5, local_orbit_seller_fee: 4) }
  let!(:monday_delivery){ create(:delivery_schedule, day: 1, market: market)}
  let!(:seller)         { create(:organization, :seller, markets: [market]) }
  let!(:product1)       { create(:product, :sellable, organization: seller, delivery_schedules: [monday_delivery])}

  let!(:product2)       { create(:product, :sellable, organization: seller, delivery_schedules: [monday_delivery])}

  let!(:buyer)          { create(:organization, :buyer, markets: [market]) }

  let!(:delivery)       { monday_delivery.next_delivery }
  let!(:order_item)     { create(:order_item, product: product1, quantity: 5, unit_price: 3.00) }
  let!(:order_item_lot) { create(:order_item_lot, quantity: 5, lot: product1.lots.first, order_item: order_item) }
  let!(:order)          { create(:order, market: market, organization: buyer, delivery: delivery, items:[order_item], payment_method: "purchase order")}

  context "as a seller" do
    let!(:user) { create(:user, organizations: [seller]) }

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      visit admin_order_path(order)
    end

    it "should not have an add items button" do
      expect(page).to_not have_content("Add Items")
    end
  end

  context "as a market manager" do
    let!(:user) { create(:user, managed_markets: [market]) }

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      visit admin_order_path(order)
    end

    it "shows the form for adding new items" do
      click_button "Add Items"
      expect(page).to have_content(product2.name)
      expect(page).to have_content(product2.organization.name)
      fill_in "items_to_add_#{product2.id}_quantity", with: 7
      click_button "Update quantities"
      expect(page).to have_content("success")
      expect(page).to have_content(product2.name)
    end
  end

  context "as an admin" do
    let!(:user) { create(:user, :admin) }

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      visit admin_order_path(order)
    end
  end
end
