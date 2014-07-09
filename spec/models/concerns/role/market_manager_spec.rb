require 'spec_helper'

describe Role::MarketManager do
  let(:user) { create(:user) }
  let(:market) { create(:market) }

  before do
    user.extend Role::MarketManager
  end

  it "is an admin" do
    expect(user.admin?).to be_falsy
  end

  it "can only manage markets where they are a manager" do
    market = create(:market, managers:[user])
    market2 = create(:market)

    expect(user.can_manage_market?(market)).to be_truthy
    expect(user.can_manage_market?(market2)).to be_falsy
  end

  it "can manage organizations that belong to a market it manages" do
    market  = create(:market, managers: [user])
    market2 = create(:market, managers: [user])
    market3 = create(:market)

    org  = create(:organization, markets: [market])
    org2 = create(:organization, markets: [market, market2])
    org3 = create(:organization, markets:[market3])

    expect(user.can_manage_organization?(org)).to be_truthy
    expect(user.can_manage_organization?(org2)).to be_truthy
    expect(user.can_manage_organization?(org3)).to be_falsy
  end

  describe ".managed_organizations" do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }

    let!(:market)  { create(:market, managers:[user]) }
    let!(:market2) { create(:market, managers: [user2]) }

    let!(:org1) { create(:organization, markets: [market]) }
    let!(:org2) { create(:organization, markets: [market2]) }

    subject { user.managed_organizations }

    it "returns organizations belonging to the market a user managers" do
      expect(subject.count).to eql(1)
      expect(subject).to include(org1)
    end
  end

  describe ".managed_products" do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }

    let!(:market) { create(:market, managers: [user1]) }
    let!(:market2) { create(:market, managers: [user2]) }

    let!(:org) { create(:organization, :seller, markets: [market]) }
    let!(:org2) { create(:organization, :seller, markets: [market2]) }
    let!(:deleted_org) { create(:organization, :seller, markets: [market]) }

    let!(:product) { create(:product, :sellable, organization: org) }
    let!(:product2) { create(:product, :sellable, organization: org2) }
    let!(:non_visible_product) { create(:product, organization: org2, deleted_at: 3.weeks.ago) }
    let!(:deleted_org_product) { create(:product, organization: deleted_org) }

    let(:subject) { user.managed_products }

    before do
      mo = deleted_org.market_organizations.first
      mo.soft_delete
    end

    it "returns all visible products from non-deleted organizations that the user manages" do
      expect(subject.count).to eql(1)
      expect(subject).to include(product)
    end
  end


end
