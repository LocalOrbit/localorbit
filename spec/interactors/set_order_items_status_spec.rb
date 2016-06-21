require "spec_helper"

describe SetOrderItemsStatus do
  let!(:user) { create(:user, :supplier) }
  let!(:market_manager) { create(:user, :market_manager) }
  let!(:market) { market_manager.managed_markets.first }
  let!(:delivery_schedule) { create(:delivery_schedule) }
  let!(:delivery)    { delivery_schedule.next_delivery }

  let!(:seller) { create(:organization, :seller, markets: [market], name: "Good foodz", users: [user]) }
  let!(:other_seller) { create(:organization, :seller, markets: [market], name: "Better foodz") }
  let!(:buyer) { create(:organization, :buyer, markets: [market], name: "Big Money") }

  let!(:product1) { create(:product, :sellable, name: "Green things", organization: seller) }
  let!(:product2) { create(:product, :sellable, name: "Purple cucumbers", organization: seller) }
  let!(:product3) { create(:product, :sellable, name: "Brocolli", organization: other_seller) }

  let!(:order_item1) { create(:order_item, product: product1, seller_name: seller.name, name: product1.name, unit_price: 6.50, quantity: 5, unit: "Bushels") }
  let!(:order_item2) { create(:order_item, product: product2, seller_name: seller.name, name: product2.name, unit_price: 5.00, quantity: 10, unit: "Lots") }
  let!(:order_item3) { create(:order_item, product: product3, seller_name: other_seller.name, name: product3.name, unit_price: 2.00, quantity: 12, unit: "Heads") }

  let!(:order) { create(:order, delivery: delivery, items: [order_item1, order_item2, order_item3], organization: buyer, order_number: "LO-ADA-0000001", placed_at: Time.zone.parse("2014-03-15")) }

  context "as a market manager" do
    it "sets the status on the order items" do
      interactor = SetOrderItemsStatus.perform(user: market_manager, delivery_status: "delivered", order_item_ids: [order_item1.id.to_s, order_item3.id.to_s])
      expect(interactor).to be_success

      order_item1.reload
      expect(order_item1.delivery_status).to eq("delivered")

      order_item3.reload
      expect(order_item3.delivery_status).to eq("delivered")
    end

    it "caches the overall status on the order" do
      expect(order.delivery_status).to eq("pending")
      interactor = SetOrderItemsStatus.perform(user: market_manager, delivery_status: 'delivered', order_item_ids: [order_item1.id.to_s, order_item3.id.to_s])
      order.reload
      expect(order.delivery_status).to eq("partially delivered")

      interactor = SetOrderItemsStatus.perform(user: market_manager, delivery_status: 'delivered', order_item_ids: [order_item2.id.to_s])
      order.reload
      expect(order.delivery_status).to eq("delivered")
    end

    it "does not set the status on order items for other markets" do
      other_prod = create(:product, :sellable)
      other_order = create(:order, :with_items, delivery: delivery)
      other_item = create(:order_item, order: other_order, product: other_prod)

      interactor = SetOrderItemsStatus.perform(user: market_manager, delivery_status: "delivered", order_item_ids: [order_item1.id.to_s, other_item.id.to_s])
      expect(interactor).to be_success

      other_item.reload
      expect(other_item.delivery_status).to eq("pending")

      order_item1.reload
      expect(order_item1.delivery_status).to eq("delivered")

      order.reload
      expect(order.delivery_status).to eq("partially delivered")
    end
  end

  context "as a seller" do
    it "sets the status on the order items" do
      interactor = SetOrderItemsStatus.perform(user: user, delivery_status: "delivered", order_item_ids: [order_item1.id.to_s, order_item2.id.to_s])
      expect(interactor).to be_success

      order_item1.reload
      expect(order_item1.delivery_status).to eq("delivered")

      order_item2.reload
      expect(order_item2.delivery_status).to eq("delivered")
    end

    it "does not set the status on order items for other markets" do
      interactor = SetOrderItemsStatus.perform(user: user, delivery_status: "delivered", order_item_ids: [order_item1.id.to_s, order_item3.id.to_s])
      expect(interactor).to be_success

      order_item3.reload
      expect(order_item3.delivery_status).to eq("pending")

      order_item1.reload
      expect(order_item1.delivery_status).to eq("delivered")
    end
  end
end
