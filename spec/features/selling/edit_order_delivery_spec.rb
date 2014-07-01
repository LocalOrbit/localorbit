require 'spec_helper'

describe "Edit order delivery date" do
  let!(:market)          { create(:market, :with_addresses, market_seller_fee: 5, local_orbit_seller_fee: 4) }
  let!(:monday_delivery) { create(:delivery_schedule, day: 1, market: market)}
  let!(:monday_pickup)   { create(:delivery_schedule, :buyer_pickup, day: 1, market: market)}
  let!(:seller)          { create(:organization, :seller, markets: [market]) }
  let!(:product_lot)     { create(:lot, quantity: 145) }
  let!(:product)         { create(:product, :sellable, organization: seller, lots: [product_lot])}

  let!(:product2)         { create(:product, :sellable, organization: seller)}

  let!(:buyer)          { create(:organization, :buyer, markets: [market]) }

  let!(:delivery)       { monday_delivery.next_delivery }
  let!(:delivery2)      { monday_pickup.next_delivery }
  let!(:order_item)     { create(:order_item, product: product, quantity: 5, unit_price: 3.00) }
  let!(:order_item_lot) { create(:order_item_lot, quantity: 5, lot: product_lot, order_item: order_item) }
  let!(:order)          { create(:order, market: market, organization: buyer, delivery: delivery, items:[order_item], payment_method: 'ach')}
  let!(:bank_account)   { create(:bank_account, :checking, :verified, bankable: buyer) }
  let!(:payment)        { create(:payment, :checking, bank_account: bank_account, orders: [order], amount: 15.00) }

  context "as a buyer" do
    let!(:user) { create(:user, organizations: [buyer]) }

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      visit admin_order_path(order)
    end

    it "gives a 404" do
      expect(page.status_code).to eql(404)
    end
  end

  context "as a seller" do
    let!(:user) { create(:user, organizations: [seller]) }

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      visit admin_order_path(order)
    end

    it "should not have a button to change the delivery" do
      expect(page).to_not have_css("#delivery-changer")
    end
  end

  context "as a market manager" do
    let!(:user) { create(:user, managed_markets: [market]) }

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
    end

    context "successfully changing the delivery" do
      before do
        visit admin_order_path(order)
        click_link "Change"
        expect(UpdateOrderDelivery).to receive(:perform).and_return(double("interactor", success?: true))
      end

      it "saves the delivery change" do
        select "Pick up:", from: "order_delivery_id"
        click_button "Change Delivery"
        expect(page).to have_content("Delivery successfully updated")
      end
    end

    context "unsuccessfully changing the delivery" do
      before do
        visit admin_order_path(order)
        click_link "Change"
        expect(UpdateOrderDelivery).to receive(:perform).and_return(double("interactor", success?: false))
      end

      it "does not save the delivery change" do
        select "Pick up:", from: "order_delivery_id"
        click_button "Change Delivery"
        expect(page).to have_content("delivery cannot be changed")
      end
    end
  end
end
