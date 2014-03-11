require 'spec_helper'

describe Order do
  context "validations" do
    it "requires an organization id" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:organization_id)
    end

    it "requires a market id" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:market_id)
    end

    it "requires a delivery id" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:delivery_id)
    end

    it "requires a order number" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:order_number)
    end

    it "requires a placed_at date" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:placed_at)
    end

    it "requires delivery fees" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:delivery_fees)
    end

    it "requires a delivery status" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:delivery_status)
    end

    it "requires a total cost" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:total_cost)
    end

    it "requires a delivery address" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:delivery_address)
    end

    it "requires a delivery city" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:delivery_city)
    end

    it "requires a delivery state" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:delivery_state)
    end

    it "requires a delivery zip" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:delivery_zip)
    end

    it "requires a delivery phone" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:delivery_phone)
    end

    it "requires a billing organization name" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:billing_organization_name)
    end

    it "requires a billing address" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:billing_address)
    end

    it "requires a billing city" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:billing_city)
    end

    it "requires a billing state" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:billing_state)
    end

    it "requires a billing zip" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:billing_zip)
    end

    it "requires a billing phone" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:billing_phone)
    end

    it "requires a payment status" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:payment_status)
    end

    it "requires a payment method" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:payment_method)
    end
  end

  describe ".orders_for_user" do
    context "admin" do
      let(:market)       { create(:market) }
      let(:organization) { create(:organization, markets: [market]) }
      let!(:user)        { create(:user, :admin) }
      let!(:order)       { create(:order, organization: organization, market: market) }
      let!(:other_order) { create(:order, organization_id: 0, market: market) }

      it "returns all orders" do
        orders = Order.orders_for_user(user)

        expect(orders).to eq(Order.all)
      end
    end

    context "market manager" do
      let!(:user)        { create(:user, :market_manager) }
      let(:market)       { user.managed_markets.first }
      let(:other_market) { create(:market) }
      let(:organization) { create(:organization, markets: [market]) }
      let(:org2)         { create(:organization, markets: [other_market], users: [user])}
      let!(:order)       { create(:order, organization: organization, market: market) }
      let!(:other_order) { create(:order, organization_id: 0, market: market) }
      let!(:other_market_order) { create(:order, organization_id: 0, market: other_market) }
      let!(:valid_other_market_order) { create(:order, organization: org2, market: other_market) }

      it "returns only managed markets orders" do
        orders = Order.orders_for_user(user)

        expect(orders.count).to eq(3)
        expect(orders).to include(order, other_order, valid_other_market_order)
      end
    end

    context "user" do
      let(:market)       { create(:market) }
      let(:organization) { create(:organization, markets: [market]) }
      let!(:user)        { create(:user, organizations:[organization]) }
      let!(:order)       { create(:order, organization: organization, market: market) }
      let!(:other_order) { create(:order, organization_id: 0, market: market) }

      it 'returns only the organizations orders' do
        orders = Order.orders_for_user(user)

        expect(orders.count).to eq(1)
        expect(orders).to include(order)
      end
    end
  end
end
