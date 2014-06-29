require "spec_helper"

describe AddItemsToOrder do
  let!(:market) { create(:market) }
  let!(:delivery_schedule) { create(:delivery_schedule, fee: 0.0, fee_type: 'fixed') }
  let!(:delivery)          { delivery_schedule.next_delivery }
  let!(:buyer)             { create(:organization) }
  let!(:order_item) { create(:order_item, unit_price: 15.00, quantity: 2) }
  let!(:order) { create(:order, organization: buyer, delivery: delivery, market: market, items: [order_item], payment_method: "purchase order") }
  let!(:product) { create(:product, :sellable, organization: order_item.product.organization)}

  context "with valid additions" do
    it "adds items to the order" do
      interactor = AddItemsToOrder.perform(order: order, item_hashes: [{product_id: product.id, quantity: 2}])
      expect(interactor).to be_success
      order.reload
      item = order.items.detect{|i| i.product == product }
      expect(item).not_to be_nil
      expect(item.quantity).to eq(2)
    end
  end

  context "with invalid quantities" do
    it "does not add items to the order" do
      quantity = product.available_inventory(delivery.deliver_on) + 1
      interactor = AddItemsToOrder.perform(order: order, item_hashes: [{product_id: product.id, quantity: quantity}])
      expect(interactor).not_to be_success
      order.reload
      item = order.items.detect{|i| i.product == product }
      expect(item).to be_nil
    end
  end
end
