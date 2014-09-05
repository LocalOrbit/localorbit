require "spec_helper"

describe User do
  describe "roles" do

    describe "#can_manage?" do
      let(:org) { create(:organization) }
      let(:user) { create(:user) }

      it "delegates to the correct method" do
        expect(user).to_receive(:can_manage_organization?).with(org)
      end
    end

    describe "#can_manage_organization?" do
      let(:org) { create(:organization) }

      context "when user is an admin" do
        let(:user) { create(:user, role: "admin") }

        it "returns true" do
          expect(user.can_manage_organization?(org)).to be true
        end
      end

      context "when the user is a market manager" do
        let(:market_manager) { create(:user, :market_manager) }
        let(:market) { market_manager.managed_markets.first }

        context "and the org is in their managed market" do
          before do
            market.organizations << org
          end

          it "returns true" do
            expect(market_manager.can_manage_organization?(org)).to be true
          end
        end

        context "and the org is not in their managed market" do
          it "returns false" do
            expect(market_manager.can_manage_organization?(org)).to be false
          end
        end
      end

      context "user does not manage any market" do
        let(:user) { create(:user, role: "user") }

        it "returns false" do
          expect(user.can_manage_organization?(org)).to be false
        end
      end
    end

    describe "#can_manage_user?" do
      let!(:org1)   { create(:organization, markets: [market1], users: [user1, user2]) }
      let!(:org2)   { create(:organization, markets: [market2], users: [user3, user4]) }
      let!(:org3)   { create(:organization, markets: [market2], users: [user5]) }

      let!(:user1)  { create(:user) }
      let!(:user2)  { create(:user) }
      let!(:user3)  { create(:user) }
      let!(:user4)  { create(:user) }
      let!(:user5)  { create(:user) }

      let!(:market1) { create(:market) }
      let!(:market2) { create(:market) }

      context "admin" do
        let!(:admin) { create(:user, role: "admin") }

        it "is true for everyone" do
          [user1, user2, user3, user4].each do |u|
            expect(admin.can_manage_user?(u)).to be_truthy
          end
        end
      end

      context "market manager" do
        let!(:market_manager) { create(:user, managed_markets: [market1]) }

        it "can manage users in organizations in their market" do
          expect(market_manager.can_manage_user?(user1)).to be_truthy
          expect(market_manager.can_manage_user?(user2)).to be_truthy
          expect(market_manager.can_manage_user?(user3)).to be_falsy
          expect(market_manager.can_manage_user?(user4)).to be_falsy
        end

        context "managing multiple markets" do
          let!(:market_manager) { create(:user, managed_markets: [market1, market2]) }

          it "can manage users in organizations in all their markets" do
            expect(market_manager.can_manage_user?(user1)).to be_truthy
            expect(market_manager.can_manage_user?(user2)).to be_truthy
            expect(market_manager.can_manage_user?(user3)).to be_truthy
            expect(market_manager.can_manage_user?(user4)).to be_truthy
          end

          context "and a user has been suspended" do
            before do
              suspend_user(user: user1, org: user1.organizations.first)
            end

            it "can still manage that suspended user" do
              expect(market_manager.can_manage_user?(user1)).to be_truthy
              expect(market_manager.can_manage_user?(user2)).to be_truthy
              expect(market_manager.can_manage_user?(user3)).to be_truthy
              expect(market_manager.can_manage_user?(user4)).to be_truthy
            end
          end
        end
      end

      context "buyer/seller" do
        let!(:buyer) { create(:user, organizations: [org1, org3]) }

        it "can manage users in organizations they belong to" do
          expect(buyer.can_manage_user?(user1)).to be_truthy
          expect(buyer.can_manage_user?(user2)).to be_truthy
          expect(buyer.can_manage_user?(user3)).to be_falsy
          expect(buyer.can_manage_user?(user4)).to be_falsy
          expect(buyer.can_manage_user?(user5)).to be_truthy
        end
      end
    end

    describe "#with_primary_market" do
      let!(:market) { create(:market) }
      let!(:market2) { create(:market) }
      let!(:organization) { create(:organization, markets: [market]) }
      let!(:organization2) { create(:organization, markets: [market2]) }

      let!(:user) { create(:user, organizations: [organization]) }
      let!(:user2) { create(:user, organizations: [organization2]) }
      let!(:market_manager) { create(:user, managed_markets: [market]) }

      it "finds all users for organizations in the market" do
        result = User.with_primary_market(market)

        expect(result).to include(user)
        expect(result).not_to include(user2)
      end

      it "finds market_managers" do
        result = User.with_primary_market(market)
        expect(result).to include(market_manager)
      end
    end

    it 'admin? returns true if role is "admin"' do
      user = build(:user)
      user.role = "admin"
      expect(user.admin?).to be true
    end

    it 'admin? returns false if role is not "admin"' do
      user = build(:user)
      user.role = "user"
      expect(user.admin?).to be false

      user.role = "manager"
      expect(user.admin?).to be false

      user.role = "something else"
      expect(user.admin?).to be false
    end

    context "#seller?" do
      it "returns true if the user is a member of any selling organizations" do
        market = create(:market)
        org = create(:organization, can_sell: true, markets: [market])
        user = create(:user, organizations: [org])
        expect(user).to be_seller
      end

      it "returns false if the user is not a member of any selling organizations" do
        user = create(:user, organizations: [create(:organization, can_sell: false)])
        expect(user).not_to be_seller
      end
    end

    context "#buyer_only?" do
      it "returns true if the user is only a buyer" do
        user = build(:user)
        expect(user).to be_buyer_only
      end

      it "returns false if the user is a seller" do
        user = build(:user)
        allow(user).to receive(:seller?).and_return(true)
        expect(user).not_to be_buyer_only
      end

      it "returns false if the user is a market manager" do
        user = build(:user)
        allow(user).to receive(:market_manager?).and_return(true)
        expect(user).not_to be_buyer_only
      end

      it "returns false if the user is an admin" do
        user = build(:user)
        allow(user).to receive(:admin?).and_return(true)
        expect(user).not_to be_buyer_only
      end
    end
  end

  describe "managed_organizations" do

    context "for an admin" do
      let!(:user) { create(:user, :admin) }
      let!(:market1) { create(:market) }
      let!(:market2) { create(:market) }
      let!(:org1) { create(:organization, :seller, markets: [market1]) }
      let!(:org2) { create(:organization, markets: [market2]) }
      let(:result) { user.managed_organizations }

      it "returns a scope with all organizations" do
        expect(result.count).to eq(2)

        expect(result).to include(org1)
        expect(result).to include(org2)
      end

      context "cross selling organizations belonging to a market" do
        let!(:cross_sell_org) { create(:organization, markets: [market2]).tap {|o| o.market_organizations.create(market: market1, cross_sell_origin_market: market2) } }

        it "returns unique results for all organizations" do
          expect(result.count).to eql(3)
          expect(result).to include(org1)
          expect(result).to include(org2)
          expect(result).to include(cross_sell_org)
        end
      end
    end

    context "for a market manager" do
      let(:user) { create(:user, :market_manager) }
      let(:market1) { user.managed_markets.first }
      let(:market2) { user.managed_markets.create!(attributes_for(:market)) }
      let(:market3) { create(:market) }

      let(:org1) { create(:organization, name: "Org 1") }
      let(:org2) { create(:organization, name: "Org 2") }
      let(:org3) { create(:organization, name: "Org 3") }
      let(:org4) { create(:organization, name: "Org 4") }
      let(:org5) { create(:organization, name: "Org 5") }
      let(:org6) { create(:organization, name: "Org 6") }
      let(:org7) { create(:organization, name: "Org 7") }

      before do
        market1.organizations << org1
        market1.organizations << org5
        market2.organizations << org2
        market2.organizations << org7
        market3.organizations << org3
        market3.organizations << org4
        market3.organizations << org7
        user.organizations << org4
        user.organizations << org5
        org6.update_cross_sells!(from_market: market3, to_ids: [market2.id])
        org7.market_organizations.where(market_id: market2).soft_delete_all
      end

      it "returns a chainable scope" do
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

      it "does not include organizations merely cross selling to the market" do
        expect(user.managed_organizations).to_not include(org6)
      end

      it "does not include organizations removed from the market" do
        expect(user.managed_organizations).to_not include(org7)
      end
    end

    context "for a user" do
      let!(:user) { create(:user, organizations: [org1, org2]) }
      let!(:market) { create(:market) }
      let!(:market2) { create(:market) }

      let!(:org1) { create(:organization, markets: [market]) }
      let!(:org2) { create(:organization, markets: [market2]) }

      it "returns a scope for the organization memberships" do
        expect(user.managed_organizations).to eq(user.organizations)
      end

      context "who has been suspended" do
        before do
          suspend_user(user: user, org: org1)
        end

        it "returns a list of organizations which the user has not been suspended from" do
          expect(user.managed_organizations).to eq([org2])
        end

        it "returns ALL organizations when passing the 'include_suspended' option" do
          expect(user.managed_organizations(include_suspended: true)).to eq([org1, org2])
        end
      end
    end
  end

  describe "managed_organizations_within_market" do
    let(:org1) { create(:organization, name: "Org 1") }
    let(:org2) { create(:organization, name: "Org 2") }
    let(:org3) { create(:organization, name: "Org 3") }
    let(:org4) { create(:organization, name: "Org 4") }
    let(:org5) { create(:organization, name: "Org 5") }

    let!(:market1) { create(:market, organizations: [org1, org5]) }
    let!(:market2) { create(:market, organizations: [org2]) }
    let!(:market3) { create(:market, organizations: [org3, org4]) }

    context "for an admin" do
      let(:user) { create(:user, :admin) }

      it "returns a scope with all organizations for the market" do
        expect(user.managed_organizations_within_market(market1)).to include(org1, org5)
        expect(user.managed_organizations_within_market(market1)).to_not include(org2, org3, org4)
      end
      it "returns a scope with all organizations not deleted for the market" do
        MarketOrganization.where(organization_id: org5.id, market_id: market1.id).first.update_attribute(:deleted_at, 1.day.ago)
        expect(user.managed_organizations_within_market(market1)).to include(org1)
        expect(user.managed_organizations_within_market(market1)).not_to include(org5)
      end

      it "returns a scope with all organizations not_cross_selling for the market" do
        MarketOrganization.where(organization_id: org5.id, market_id: market1.id).first.update_attribute(:cross_sell_origin_market_id, true)
        expect(user.managed_organizations_within_market(market1)).to include(org1)
        expect(user.managed_organizations_within_market(market1)).not_to include(org5)
      end
    end

    context "for a market manager" do
      let(:user) { create(:user, managed_markets: [market1, market2], organizations: [org4, org5]) }

      it "returns a chainable scope" do
        expect(user.managed_organizations_within_market(market1)).to be_a_kind_of(ActiveRecord::Relation)
      end

      it "includes organizations in the market they manage" do
        expect(user.managed_organizations_within_market(market1)).to include(org1, org5)
        expect(user.managed_organizations_within_market(market1)).to_not include(org2, org3, org4)
      end

      it "includes their organizations in the market they do not manage" do
        expect(user.managed_organizations_within_market(market3)).to include(org4)
        expect(user.managed_organizations_within_market(market3)).to_not include(org1, org2, org3, org5)
      end
    end

    context "for a user" do
      let(:user) { create(:user, role: "user", organizations: [org1, org5]) }

      it "returns a scope for the organization memberships within the market" do
        expect(user.managed_organizations_within_market(market1)).to include(org1, org5)
        expect(user.managed_organizations_within_market(market1)).to_not include(org2, org3, org4)
      end

      it "returns a scope with all organizations not deleted for the market" do
        MarketOrganization.where(organization_id: org5.id, market_id: market1.id).first.update_attribute(:deleted_at, 1.day.ago)
        expect(user.managed_organizations_within_market(market1)).to include(org1)
        expect(user.managed_organizations_within_market(market1)).not_to include(org5)
      end

      it "returns a scope with all organizations not_cross_selling for the market" do
        MarketOrganization.where(organization_id: org5.id, market_id: market1.id).first.update_attribute(:cross_sell_origin_market_id, true)
        expect(user.managed_organizations_within_market(market1)).to include(org1)
        expect(user.managed_organizations_within_market(market1)).not_to include(org5)
      end

      context "user is suspended from an organization" do
        before do
          suspend_user(user: user, org: org1)
        end

        it "will not return organizations a user is suspended from" do
          expect(user.managed_organizations_within_market(market1)).to include(org5)
          expect(user.managed_organizations_within_market(market1)).not_to include(org1, org3, org4)
        end
      end
    end
  end

  describe "markets" do
    context "admin" do
      let(:user) { create(:user, :admin) }

      it "returns all markets" do
        expect(user.markets).to eq(Market.all)
      end
    end

    context "market manager" do
      let(:user) { create(:user, :market_manager) }
      let(:market1) { user.managed_markets.first }
      let(:market2) { create(:market) }
      let(:market3) { create(:market) }
      let(:org) { create(:organization) }

      before(:each) do
        user.organizations << org
        market2.organizations << org
      end

      it "returns a relation object" do
        expect(user.markets).to be_kind_of(ActiveRecord::Relation)
      end

      it "belongs to the markets they manage" do
        expect(user.markets).to include(market1)
      end

      it "belongs to markets their organizations belong to" do
        expect(user.markets).to include(market2)
      end

      it "does not show markets for which they are not members" do
        expect(user.markets).to_not include(market3)
      end

      context "user is a  member of an organization which was deleted" do
        let!(:empty_market) { create(:market, organizations: [], managers: [user]) }
        let!(:deleted_organization) { create(:organization, markets: [empty_market]) }

        before do
          mo = MarketOrganization.where(market_id: empty_market.id, organization_id: deleted_organization.id)
          mo.soft_delete
        end

        it "still returns markets the user manages" do
          expect(user.markets).to include(empty_market)
        end
      end

    end

    context "user" do
      let(:user) { create(:user, role: "user") }
      let(:market1) { create(:market) }
      let(:market2) { create(:market) }
      let(:org) { create(:organization) }

      before(:each) do
        user.organizations << org
        market1.organizations << org
      end

      it "returns a relation object" do
        expect(user.markets).to be_kind_of(ActiveRecord::Relation)
      end

      it "belongs to markets their organizations belong to" do
        expect(user.markets).to include(market1)
      end

      it "does not show markets for which they are not members" do
        expect(user.markets).to_not include(market2)
      end
    end
  end

  describe "managed_products" do
    subject { user.managed_products }

    context "for an admin" do
      let!(:user) { create(:user, :admin) }

      xit "returns all products" do
        Timecop.freeze do
          expect(subject).to eq(Product.visible.seller_can_sell.joins(organization: :market_organizations))
        end
      end
    end

    context "for a market manager" do
      let!(:user) { create(:user, :market_manager) }
      let!(:market1) { user.managed_markets.first }
      let!(:market2) { create(:market) }
      let!(:org1) { create(:organization, markets: [market1]) }
      let!(:org2) { create(:organization, markets: [market2]) }
      let!(:prod1) { create(:product, organization: org1) }
      let!(:prod2) { create(:product, organization: org2) }
      let!(:deleted_prod) { create(:product, organization: org1, deleted_at: 1.minute.ago) }

      it "returns a scope" do
        expect(subject).to be_kind_of(ActiveRecord::Relation)
      end

      it "returned scope includes products for organizations in markets they manage" do
        expect(subject).to include(prod1)
      end

      it "returned scope does not include products for organizations in markets they do not manage" do
        expect(subject).to_not include(prod2)
      end

      it "returned scope does not include deleted products" do
        expect(subject).to_not include(deleted_prod)
      end
    end

    context "for a user" do
      let!(:user) { create(:user) }
      let!(:market1) { create(:market) }
      let!(:org1) { create(:organization, markets: [market1], users: [user]) }
      let!(:org2) { create(:organization, markets: [market1]) }
      let!(:prod1) { create(:product, organization: org1) }
      let!(:prod2) { create(:product, organization: org2) }
      let!(:deleted_prod) { create(:product, organization: org1, deleted_at: 1.minute.ago) }

      it "returns a scope" do
        expect(subject).to be_kind_of(ActiveRecord::Relation)
      end

      it "returned scope includes products for organizations they belong to" do
        expect(subject).to include(prod1)
      end

      it "returned scope does not include products for organization they do not belong to" do
        expect(subject).to_not include(prod2)
      end

      it "returned scope does not include deleted products" do
        expect(subject).to_not include(deleted_prod)
      end
    end
  end

  describe "token authentication" do
    let!(:user) { create(:user) }

    describe "#auth_token" do
      it "returns a token string" do
        expect(user.auth_token).to be_a(String)
      end
    end

    describe ".for_auth_token" do
      it "returns the user for a valid token" do
        expect(User.for_auth_token(user.auth_token)).to eq(user)
      end

      it "returns nil for a blank token" do
        expect(User.for_auth_token(nil)).to be_nil
        expect(User.for_auth_token("")).to be_nil
      end

      it "returns nil for an expired token" do
        expect(User.for_auth_token(user.auth_token(-10.minutes))).to be_nil
      end

      it "return nil for an invalid token" do
        expect(User.for_auth_token("not-gonna-do-it")).to be_nil
      end
    end
  end

  describe "#primary_market" do
    context "as a market manager" do
      let!(:user) { create(:user, :market_manager) }

      it "returns the primary market" do
        expect(user.primary_market).to eq(user.markets.first)
      end
    end

    context "as an admin" do
      let!(:user) { create(:user, :admin) }

      it "returns nil" do
        expect(user.primary_market).to eq(nil)
      end
    end
  end

  context "oranizations scopes" do
    let!(:market) { create(:market) }
    let!(:user) { create(:user) }
    let!(:org1) { create(:organization, users: [user], markets: [market]) }
    let!(:org2) { create(:organization, users: [user], markets: [market]) }

    describe "#organizations" do
      let(:result) { user.organizations }

      it "returns the organizations the user belongs to" do
        expect(result.count).to eql(2)
        expect(result).to include(org1)
        expect(result).to include(org2)
      end

      context "when the user has been suspended from an organization" do
        before do
          suspend_user(user: user, org: org1)
        end

        it "does not return organizations where the user is suspended" do
          expect(result.count).to eql(1)
          expect(result).not_to include(org1)
          expect(result).to include(org2)
        end
      end
    end

    describe "#organizations_including_suspended" do
      let(:result) { user.organizations_including_suspended }

      before do
        suspend_user(user: user, org: org1)
      end

      context "when the user has been suspended from an organization" do
        it "returns all organizations a user is associated with including suspended" do
          expect(result.count).to eql(2)
          expect(result).to include(org1)
          expect(result).to include(org2)
        end
      end
    end

    describe "#suspended_organizations" do
      let(:result) { user.suspended_organizations }
      before do
        suspend_user(user: user, org: org1)
      end

      it "returns all organizations a user is suspended from" do
        expect(result.count).to eql(1)

        expect(result).to include(org1)
        expect(result).not_to include(org2)
      end
    end
  end
end
