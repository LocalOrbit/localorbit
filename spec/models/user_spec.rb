require 'spec_helper'

describe User do
  describe 'roles' do
    it 'admin? returns true if role is "admin"' do
      user = build(:user)
      user.role = 'admin'
      expect(user.admin?).to be_true
    end

    it 'admin? returns false if role is not "admin"' do
      user = build(:user)
      user.role = 'user'
      expect(user.admin?).to be_false

      user.role = 'manager'
      expect(user.admin?).to be_false

      user.role = 'something else'
      expect(user.admin?).to be_false
    end
  end

  describe 'managed_organizations' do

    context 'for an admin' do
      let(:user) { create(:user) }

      it 'returns a scope with all organizations' do
        expect(user.managed_organizations).to eq(Organization.all)
      end
    end

    context 'for a market manager' do
      let(:user) { create(:user, :market_manager) }
      let(:market1) { user.managed_markets.first }
      let(:market2) { user.managed_markets.create(attributes_for(:market)) }
      let(:market3) { create(:market) }

      let(:org1) { create(:organization, name: 'Org 1') }
      let(:org2) { create(:organization, name: 'Org 2') }
      let(:org3) { create(:organization, name: 'Org 3') }
      let(:org4) { create(:organization, name: 'Org 4') }
      let(:org5) { create(:organization, name: 'Org 5') }

      before do
        market1.organizations << org1
        market1.organizations << org5
        market2.organizations << org2
        market3.organizations << org3
        market3.organizations << org4
        user.organizations << org4
        user.organizations << org5
      end

      it 'returns a chainable scope' do
        expect(user.managed_organizations).to be_a_kind_of(ActiveRecord::Relation)
      end

      it "includes organizations in their managed markets" do
        expect(user.managed_organizations).to include(org1, org2)
      end

      it "includes organizations they directly belong to" do
        expect(user.managed_organizations).to include(org4, org5)
      end

      it "does not include organizations in other markets" do
        expect(user.managed_organizations).to_not include(org3)
      end
    end

    context 'for a user' do
      let(:user) { create(:user, role: 'user') }

      it 'returns a scope for the organization memberships' do
        expect(user.managed_organizations).to eq(user.organizations)
      end
    end
  end
end
