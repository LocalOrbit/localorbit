require "spec_helper"

context "Viewing sold items" do
  let(:market) { create(:market) }

  let!(:buyer) { create(:organization, :buyer, name: "Big Money", markets: [market]) }
  let!(:seller) { create(:organization, :seller, name: "Good foodz", markets: [market]) }
  let!(:seller2) { create(:organization, :seller, name: "Better foodz", markets: [market]) }
  let!(:product1) { create(:product, :sellable, name: "Green things", organization: seller) }
  let!(:product2) { create(:product, :sellable, name: "Purple cucumbers", organization: seller) }
  let!(:product3) { create(:product, :sellable, name: "Brocolli", organization: seller2) }
  let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
  let!(:delivery) { create(:delivery, delivery_schedule: delivery_schedule) }
  let!(:order) { create(:order, organization: buyer, market: market, delivery: delivery, order_number: "LO-ADA-0000001", placed_at: Time.zone.parse("2014-03-15")) }
  let!(:order_item1) { create(:order_item, order: order, product: product1, seller_name: seller.name, name: product1.name, unit_price: 6.50, quantity: 5, unit: "Bushels") }
  let!(:order_item2) { create(:order_item, order: order, product: product2, seller_name: seller.name, name: product2.name, unit_price: 5.00, quantity: 10, unit: "Lots") }
  let!(:order_item3) { create(:order_item, order: order, product: product3, seller_name: seller2.name, name: product3.name, unit_price: 2.00, quantity: 12, unit: "Heads") }

  before(:each) do
    switch_to_subdomain(market.subdomain)
  end

  context "as a market manager" do
    let(:market_manager) { create :user, managed_markets: [market] }

    before do
      sign_in_as market_manager
      visit admin_order_items_path
    end

    it "lists all sold items for the market" do
      sold_items = Dom::Admin::SoldItemRow.all

      expect(sold_items.count).to eq(3)

      sold_item = Dom::Admin::SoldItemRow.first

      expect(sold_item.order_number).to have_content("LO-ADA-0000001")
      expect(sold_item.order_date).to eq("03/15/2014")
      expect(sold_item.buyer).to eq("Big Money")
      expect(sold_item.seller).to eq("Better foodz")
      expect(sold_item.product).to eq("Brocolli")
      expect(sold_item.quantity).to eq("12")
      expect(sold_item.total_price).to eq("$24.00")
      expect(sold_item.unit_price).to eq("$2.00/Heads")
      expect(sold_item.delivery_status).to eq("Pending")
      expect(sold_item.buyer_payment_status).to eq("Unpaid")
      expect(sold_item.seller_payment_status).to eq("Unpaid (WIP)")
    end

    it "sets item delivery status" do
      sold_item = Dom::Admin::SoldItemRow.first
      sold_item.select
      select 'Delivered', from: 'delivery_status'
      click_button 'Apply Action'

      sold_items = Dom::Admin::SoldItemRow.all
      expect(sold_items[0].delivery_status).to eq("Delivered")
      expect(sold_items[1].delivery_status).to eq("Pending")
      expect(sold_items[2].delivery_status).to eq("Pending")

      Dom::Admin::SoldItemRow.all.each(&:select)
      select 'Delivered', from: 'delivery_status'
      click_button 'Apply Action'

      sold_items = Dom::Admin::SoldItemRow.all
      expect(sold_items[0].delivery_status).to eq("Delivered")
      expect(sold_items[1].delivery_status).to eq("Delivered")
      expect(sold_items[2].delivery_status).to eq("Delivered")
    end
  end

  context "as a seller" do
    let(:user) { create(:user, organizations: [seller]) }

    before do
      sign_in_as user
      visit admin_order_items_path
    end

    it "lists all sold items for the seller organization" do
      sold_items = Dom::Admin::SoldItemRow.all

      expect(sold_items.count).to eq(2)

      sold_item = Dom::Admin::SoldItemRow.first

      expect(sold_item.order_number).to have_content("LO-ADA-0000001")
      expect(sold_item.order_date).to eq("03/15/2014")
      expect(sold_item.buyer).to eq("Big Money")
      expect(sold_item.seller).to eq("Good foodz")
      expect(sold_item.product).to eq("Green things")
      expect(sold_item.quantity).to eq("5")
      expect(sold_item.total_price).to eq("$32.50")
      expect(sold_item.unit_price).to eq("$6.50/Bushels")
      expect(sold_item.delivery_status).to eq("Pending")
      expect(sold_item.buyer_payment_status).to eq("Unpaid")
      expect(sold_item.seller_payment_status).to eq("Unpaid (WIP)")
    end
  end
end
