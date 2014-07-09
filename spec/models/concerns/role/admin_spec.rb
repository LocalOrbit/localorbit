require 'spec_helper'

describe Role::Admin do
  let(:user) { create(:user, role: "admin") }
  let(:market) { create(:market) }

  before do
    user.extend Role::Admin
  end

  it "is an admin" do
    expect(user.admin?).to be_truthy
  end

  it "manages all markets" do
    market = create(:market)
    market2 = create(:market)

    expect(user.can_manage_market?(market)).to be_truthy
    expect(user.can_manage_market?(market2)).to be_truthy
  end

  it "manages all organizations" do
    org = create(:organization)
    org2 = create(:organization)

    expect(user.can_manage_organization?(org)).to be_truthy
    expect(user.can_manage_organization?(org2)).to be_truthy
  end

  describe ".managed_organizations" do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:org1) { create(:organization, users:[user1])}
    let!(:org2) { create(:organization, users:[user2])}
    subject { user.managed_organizations }

    it "returns all orgamizations" do
      expect(subject.count).to eql(2)
      expect(subject).to include(org1, org2)
    end
  end

  describe ".managed_products" do
    let!(:market) { create(:market) }

    let!(:org) { create(:organization, :seller, markets: [market]) }
    let!(:org2) { create(:organization, :seller, markets: [market]) }
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

    it "returns all visible products from non-deleted organizations" do
      expect(subject.count).to eql(2)
      expect(subject).to include(product, product2)
    end
  end


end
