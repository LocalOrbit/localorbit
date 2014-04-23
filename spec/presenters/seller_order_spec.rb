require "spec_helper"

describe SellerOrder do
  let!(:seller) { create(:user, :seller) }
  let!(:product) { create(:product, :sellable, organization: seller.organizations.first) }
  let!(:items) { create_list(:order_item, 3, product: product, delivery_status: "pending") }
  let!(:order) { create(:order, items: items, organization: seller.organizations.first, market: seller.markets.first) }
  let!(:seller_order) { SellerOrder.new(order, seller) }

  describe "#delivery_status" do
    subject { seller_order.delivery_status }

    context "when all items pending" do
      it { should eq("pending") }
    end

    context "when all items canceled" do
      before { OrderItem.update_all(delivery_status: "canceled") }
      it { should eq("canceled") }
    end

    context "when all items delivered" do
      before { OrderItem.update_all(delivery_status: "delivered") }
      it { should eq("delivered") }
    end

    context "when at least one item is pending and delivered" do
      before { items.first.update_attributes(delivery_status: "delivered") }
      it { should eq("partially delivered") }
    end

    context "when any item is contested" do
      before { items.first.update_attributes(delivery_status: "contested") }
      it { should eq("contested") }
    end

    context "when at least one item is contested, delivered, and pending" do
      before do
        items.first.update_attributes(delivery_status: "contested")
        items.last.update_attributes(delivery_status: "delivered")
      end

      it { should eq("contested, partially delivered") }
    end
  end
end
