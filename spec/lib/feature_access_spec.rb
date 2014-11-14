require "spec_helper"

describe FeatureAccess do
  let(:plan)                   { create(:plan, :grow) }
  let!(:market)                { create(:market, :with_delivery_schedule, :with_address, plan: plan) }
  let!(:wrong_market)          { create(:market, :with_delivery_schedule, :with_address, plan: plan) }
  let!(:buyer)                 { create(:organization, :buyer, markets: [market]) }
  let!(:wrong_organization)    { create(:organization, :buyer, markets: [market]) }
  let(:order)                  { create :order, :with_items, organization: buyer, market: market }
  let(:user)                   { create(:user, organizations: [buyer]) }

  before do
    user.markets << market
  end

  describe "#order_printables?" do
    it "returns false if the user does not belong to the order's market" do
      order.market = wrong_market
      order.save
      expect(FeatureAccess.order_printables?(user: user, order: order)).to eq false
    end

    it "returns false for start up markets" do
      plan = create(:plan, :start_up)
      market.plan = plan
      market.save
      expect(FeatureAccess.order_printables?(user: user, order: order)).to eq false
    end

    it "returns false for non market managers who did not place the order" do
      user.organizations = [wrong_organization]
      user.save
      expect(FeatureAccess.order_printables?(user: user, order: order)).to eq false
    end

    it "returns true otherwise" do
      expect(FeatureAccess.order_printables?(user: user, order: order)).to eq true
    end

    it "always returns true for admins" do
      plan = create(:plan, :start_up)
      market.plan = plan
      market.save
      user.role = "admin"
      user.save
      expect(FeatureAccess.order_printables?(user: user, order: order)).to eq true
    end
  end

end