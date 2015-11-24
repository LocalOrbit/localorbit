require "spec_helper"

describe SellerOrder do
  let!(:market)   { create(:market) }
  let!(:delivery_schedule) { create(:delivery_schedule) }
  let!(:delivery)    { delivery_schedule.next_delivery }

  let!(:buyer)    { create(:organization, :buyer, markets: [market]) }
  let!(:seller1)  { create(:organization, :seller, markets: [market]) }
  let!(:seller2)  { create(:organization, :seller, markets: [market]) }
  let!(:product1) { create(:product, :sellable, organization: seller1, name: "Product 1") }
  let!(:product2) { create(:product, :sellable, organization: seller2, name: "Product 2") }
  let!(:product3) { create(:product, :sellable, organization: seller1, name: "Product 3") }
  let!(:product4) { create(:product, :sellable, organization: seller1, name: "Product 4") }
  let!(:item1)    { create(:order_item, product: product1, delivery_status: "pending") }
  let!(:item2)    { create(:order_item, product: product2, delivery_status: "pending") }
  let!(:item3)    { create(:order_item, product: product3, delivery_status: "pending") }
  let!(:item4)    { create(:order_item, product: product4, delivery_status: "pending") }
  let!(:order)    { create(:order, delivery: delivery, items: [item1, item2, item3, item4], organization: buyer, market: market) }
  let!(:user)     { create(:user, :admin) }


  describe "#seller and #seller_id" do
    it "provides Seller org and the id of the seller org" do
      seller_order = SellerOrder.new(order, seller1)
      expect(seller_order.seller).to eq seller1
      expect(seller_order.seller_id).to eq seller1.id
    end
  end

  describe "#items" do
    it "loads the right items for seller 1 organization" do
      seller_order = SellerOrder.new(order, seller1)

      expect(seller_order.items).to eq([item1, item3, item4])
    end

    it "loads the right items for seller 2 organization" do
      seller_order = SellerOrder.new(order, seller2)

      expect(seller_order.items).to eq([item2])
    end

    it "loads the right items for seller 1 user" do
      seller_order = SellerOrder.new(order, create(:user, organizations: [seller1]))

      expect(seller_order.items).to eq([item1, item3, item4])
    end

    it "loads the right items for seller 2 user" do
      seller_order = SellerOrder.new(order, create(:user, organizations: [seller2]))

      expect(seller_order.items).to eq([item2])
    end

    it "loads all items for a market manager" do
      seller_order = SellerOrder.new(order, create(:user, managed_markets: [market]))

      expect(seller_order.items).to eq([item1, item2, item3, item4])
    end

    it "loads all items for an admin" do
      seller_order = SellerOrder.new(order, create(:user, :admin))

      expect(seller_order.items).to eq([item1, item2, item3, item4])
    end
  end

  describe "#delivery_status_for_user" do
    subject { SellerOrder.new(order, seller1).delivery_status_for_user(user) }

    context "when all items pending" do
      it { should eq("pending") }
    end

    context "when all items canceled" do
      before { OrderItem.update_all(delivery_status: "canceled") }
      it { should eq("canceled") }
    end

    context "when one item is canceled" do
      it "returns the remaining delivery status" do
        order.items.first.update(delivery_status: "canceled")

        expect(SellerOrder.new(order, seller1).delivery_status_for_user(user)).to eq("pending")
      end
    end

    context "when all items delivered" do
      before { OrderItem.update_all(delivery_status: "delivered") }
      it { should eq("delivered") }
    end

    it "when all items delivered for this seller" do
      item1.update_attributes(delivery_status: "delivered")
      item3.update_attributes(delivery_status: "delivered")
      item4.update_attributes(delivery_status: "delivered")

      expect(SellerOrder.new(order, seller1).delivery_status_for_user(user)).to eq("delivered")
    end

    context "when at least one item is pending and delivered" do
      before { item1.update_attributes(delivery_status: "delivered") }
      it { should eq("partially delivered") }
    end

    context "when any item is contested" do
      before { item1.update_attributes(delivery_status: "contested") }
      it { should eq("contested") }
    end

    context "when at least one item is contested, delivered, and pending" do
      before do
        item1.update_attributes(delivery_status: "contested")
        item3.update_attributes(delivery_status: "delivered")
      end

      it { should eq("contested, partially delivered") }
    end
  end

  describe "#credit_amount" do
    it "returns 0 when there is no credit" do
      expect(SellerOrder.new(order, seller1).credit_amount).to eq 0
    end

    it "returns 0 when the credit is paid by the market" do
      create(:credit, order: order, payer_type: Credit::MARKET, amount_type: Credit::FIXED, amount: 1)
      expect(SellerOrder.new(order, seller1).credit_amount).to eq 0
    end

    it "returns an amount proportional to the number of sellers when the credit is paid by sellers in general" do
      create(:credit, order: order, payer_type: Credit::ORGANIZATION, paying_org: nil, amount_type: Credit::FIXED, amount: 1)
      expect(SellerOrder.new(order, seller1).credit_amount).to eq 0.50
    end

    it "returns the full credited amount when the current seller is responsible for the credit" do
      create(:credit, order: order, payer_type: Credit::ORGANIZATION, paying_org: seller1, amount_type: Credit::FIXED, amount: 1)
      expect(SellerOrder.new(order, seller1).credit_amount).to eq 1
    end
  end

  describe "#total_cost" do
    it "takes the credit amount the seller is responsible for into account" do
      expect(SellerOrder.new(order, seller1).total_cost).to eq 20.97
      credit = create(:credit, order: order, payer_type: Credit::ORGANIZATION, paying_org: seller1, amount_type: Credit::FIXED, amount: 1)
      order.credit = credit
      order.save
      expect(SellerOrder.new(order, seller1).total_cost).to eq 19.97
    end
  end
end
