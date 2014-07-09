require "spec_helper"

describe Role do
  describe ".for" do
    let(:user) { create(:user) }
    subject { Role.for(user: user, market: market) }

    it "requires a user and a market" do
      expect {
        Role.for
      }.to raise_error
    end

    context "User is an admin" do
      let(:user) { create(:user, role: "admin") }
      let(:market) { create(:market) }
      it { is_expected.to eql(Role::Admin) }
    end

    context "User can manage the market" do
      let(:market) { create(:market, managers: [user])}
      it { is_expected.to eql(Role::MarketManager) }

      context "but is also an admin" do
        let(:user) { create(:user, role: "admin") }
        it { is_expected.to eql(Role::Admin) }
      end
    end

    context "User belongs to an organization in the market" do
      let(:market) { create(:market)}
      let!(:seller) { create(:organization, users: [user], markets: [market]) }
      it { is_expected.to eql(Role::OrganizationMember) }
    end

    context "User is not in market and not in organization for market" do
      let(:market) { create(:market)}
      let(:market2) { create(:market)}
      let!(:seller) { create(:organization, users: [user], markets: [market2]) }
      expect {
        subject
      }.to raise_error(User::RoleError)
    end
  end
end
