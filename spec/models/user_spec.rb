require 'spec_helper'

describe User do
  describe 'roles' do

    describe '#can_manage?' do
      let(:market) { create(:market) }
      let(:org) { create(:organization) }
      let(:other_user) { create(:user) }
      let(:user) { create(:user) }

      it 'delegates to the correct method' do
        expect(user).to receive(:can_manage_organization?).with(org)
        user.can_manage?(org)

        expect(user).to receive(:can_manage_market?).with(market)
        user.can_manage?(market)

        expect(user).to receive(:can_manage_user?).with(other_user)
        user.can_manage?(other_user)
      end
    end

    describe '#can_manage_organization?' do
      let(:org) { create(:organization) }

      context 'when user is an admin' do
        let(:user) { create(:user, :admin) }

        it 'returns true' do
          expect(user.can_manage_organization?(org)).to be true
        end
      end

      context 'when the user is a market manager' do
        let(:market_manager) { create(:user, :market_manager) }
        let(:market) { market_manager.managed_markets.first }

        context 'and the org is in their managed market' do
          before do
            market.organizations << org
          end

          it 'returns true' do
            expect(market_manager.can_manage_organization?(org)).to be true
          end
        end

        context 'and the org is not in their managed market' do
          it 'returns false' do
            expect(market_manager.can_manage_organization?(org)).to be false
          end
        end
      end

      context 'user does not manage any market' do
        let(:user) { create(:user) }

        it 'returns false' do
          expect(user.can_manage_organization?(org)).to be false
        end
      end
    end

    describe '#can_manage_user?' do
      let!(:org1)   { create(:organization, :seller, markets: [market1], users: [user1, user2]) }
      let!(:org2)   { create(:organization, :seller, markets: [market2], users: [user3, user4]) }
      let!(:org3)   { create(:organization, :seller, markets: [market2], users: [user5]) }

      let!(:user1)  { create(:user, :supplier) }
      let!(:user2)  { create(:user, :supplier) }
      let!(:user3)  { create(:user, :supplier) }
      let!(:user4)  { create(:user, :supplier) }
      let!(:user5)  { create(:user) }

      let!(:market1) { create(:market) }
      let!(:market2) { create(:market) }

      context "admin" do
        let!(:admin) { create(:user, :admin) }

        it 'is true for everyone' do
          [user1, user2, user3, user4].each do |u|
            expect(admin.can_manage_user?(u)).to be_truthy
          end
        end
      end

      context 'market manager' do
        let!(:market_manager) { create(:user, :market_manager, managed_markets: [market1]) }

        it 'can manage users in organizations in their market' do
          expect(market_manager.can_manage_user?(user1)).to be_truthy
          expect(market_manager.can_manage_user?(user2)).to be_truthy
          expect(market_manager.can_manage_user?(user3)).to be_falsy
          expect(market_manager.can_manage_user?(user4)).to be_falsy
        end

        context 'managing multiple markets' do
          let!(:market_manager) { create(:user, :market_manager, managed_markets: [market1, market2]) }

          it 'can manage users in organizations in all their markets' do
            expect(market_manager.can_manage_user?(user1)).to be_truthy
            expect(market_manager.can_manage_user?(user2)).to be_truthy
            expect(market_manager.can_manage_user?(user3)).to be_truthy
            expect(market_manager.can_manage_user?(user4)).to be_truthy
          end

          context 'and a user has been suspended' do
            before do
              suspend_user(user: user1, org: user1.organizations.first)
            end

            it 'can still manage that suspended user' do
              expect(market_manager.can_manage_user?(user1)).to be_truthy
              expect(market_manager.can_manage_user?(user2)).to be_truthy
              expect(market_manager.can_manage_user?(user3)).to be_truthy
              expect(market_manager.can_manage_user?(user4)).to be_truthy
            end
          end
        end
      end

      context 'buyer/seller' do
        let!(:buyer) { create(:user, :supplier, organizations: [org1, org3]) }

        it 'can manage users in organizations they belong to' do
          expect(buyer.can_manage_user?(user1)).to be_truthy
          expect(buyer.can_manage_user?(user2)).to be_truthy
          expect(buyer.can_manage_user?(user3)).to be_falsy
          expect(buyer.can_manage_user?(user4)).to be_falsy
          expect(buyer.can_manage_user?(user5)).to be_truthy
        end
      end
    end

    it 'admin? returns true if role is "admin"' do
      user = create(:user, :admin)
      org = create(:organization, :admin)
      user.organizations << org

      #user.role = "admin"
      expect(user.admin?).to be true
    end

    it 'admin? returns false if role is not "admin"' do
      user = build(:user, :supplier)
      org = build(:organization, :seller)
      user.organizations << org
      expect(user.admin?).to be false
    end

    context '#seller?' do
      it 'returns true if the user is a member of any selling organizations' do
        market_org = create(:organization, :market)
        market = create(:market, organization: market_org)
        org = create(:organization, :seller, markets: [market])
        user = create(:user, :supplier, organizations: [org])
        expect(user).to be_seller
      end

      it 'returns false if the user is not a member of any selling organizations' do
        user = create(:user, :buyer, organizations: [create(:organization, :buyer)])
        expect(user).not_to be_seller
      end

      it 'returns false if user is an admin' do
        market_org = create(:organization, :market)
        market = create(:market, organization: market_org)
        org = create(:organization, :seller, markets: [market])
        user = create(:user, :supplier, organizations: [org])
        # HACK, set this up properly
        allow(user).to receive(:admin?).and_return(true)
        expect(user).not_to be_seller
      end

    end

    context '#buyer_only?' do
      it 'returns true if the user is only a buyer' do
        user = create(:user, :buyer)
        org = create(:organization, :buyer)
        user.organizations << org
        expect(user).to be_buyer_only
      end

      it 'returns false if the user is a seller' do
        user = build(:user, :supplier)
        allow(user).to receive(:seller?).and_return(true)
        expect(user).not_to be_buyer_only
      end

      it 'returns false if the user is a market manager' do
        user = build(:user, :market_manager)
        allow(user).to receive(:market_manager?).and_return(true)
        expect(user).not_to be_buyer_only
      end

      it 'returns false if the user is an admin' do
        user = create(:user, :buyer)
        org = create(:organization, :buyer)
        user.organizations << org
        # HACK, set this up properly
        allow(user).to receive(:admin?).and_return(true)
        expect(user).not_to be_buyer_only
      end
    end
  end

  describe 'managed_organizations' do

    context 'for an admin' do
      let!(:user) { create(:user, :admin) }
      let!(:market_org1) { create(:organization, :market) }
      let!(:market1) { create(:market, organization: market_org1) }
      let!(:market_org2) { create(:organization, :market) }
      let!(:market2) { create(:market, organization: market_org2) }
      let!(:org1) { create(:organization, :seller, markets: [market1]) }
      let!(:org2) { create(:organization, :seller, markets: [market2]) }
      let(:result) { user.managed_organizations }

      it 'returns a scope with all organizations' do
        expect(result.count).to eq(2)

        expect(result).to include(org1)
        expect(result).to include(org2)
      end

      context 'cross selling organizations belonging to a market' do
        let!(:cross_sell_org) { create(:organization, markets: [market2]).tap {|o| o.market_organizations.create(market: market1, cross_sell_origin_market: market2) } }

        it 'returns unique results for all organizations' do
          expect(result.count).to eql(3)
          expect(result).to include(org1)
          expect(result).to include(org2)
          expect(result).to include(cross_sell_org)
        end
      end
    end

    context 'for a market manager' do


      let(:org1) { create(:organization, name: 'Org 1') }
      let(:org2) { create(:organization, name: 'Org 2') }
      let(:org3) { create(:organization, name: 'Org 3') }
      let(:org4) { create(:organization, name: 'Org 4') }
      let(:org5) { create(:organization, name: 'Org 5') }
      let(:org6) { create(:organization, name: 'Org 6') }
      let(:org7) { create(:organization, name: 'Org 7') }

      let(:market1) { create(:market, organizations:[org1,org5]) }
      let(:market2) { create(:market, organizations:[org2,org7]) }
      let(:market3) { create(:market, organizations:[org3,org4,org7]) }

      let(:user) { create(:user, :market_manager) }

      before do
        #market1.organizations << org1
        #market1.organizations << org5
        #market2.organizations << org2
        #market2.organizations << org7
        #market3.organizations << org3
        #market3.organizations << org4
        #market3.organizations << org7
        user.managed_organizations << org1
        user.managed_organizations << org2
        user.managed_organizations << org4
        user.managed_organizations << org5
        org6.update_cross_sells!(from_market: market3, to_ids: [market2.id])
        org7.market_organizations.where(market_id: market2).soft_delete_all
      end

      it 'returns a chainable scope' do
        expect(user.managed_organizations).to be_a_kind_of(ActiveRecord::Relation)
      end

      it 'includes organizations in their managed markets' do
        expect(user.managed_organizations).to include(org1, org2)
      end

      it 'includes organizations they directly belong to' do
        expect(user.managed_organizations).to include(org4, org5)
      end

      it 'does not include organizations in other markets' do
        expect(user.managed_organizations).to_not include(org3)
      end

      it 'does not include organizations merely cross selling to the market' do
        expect(user.managed_organizations).to_not include(org6)
      end

      it 'does not include organizations removed from the market' do
        expect(user.managed_organizations).to_not include(org7)
      end
    end

    context 'for a user' do
      let!(:user) { create(:user, organizations: [org1, org2]) }
      let!(:market) { create(:market) }
      let!(:market2) { create(:market) }

      let!(:org1) { create(:organization, markets: [market]) }
      let!(:org2) { create(:organization, markets: [market2]) }

      it 'returns a scope for the organization memberships' do
        expect(user.managed_organizations).to eq(user.organizations)
      end

      context 'who has been suspended' do
        before do
          suspend_user(user: user, org: org1)
        end

        it 'returns a list of organizations which the user has not been suspended from' do
          expect(user.managed_organizations).to eq([org2])
        end

        it "returns ALL organizations when passing the 'include_suspended' option" do
          expect(user.managed_organizations(include_suspended: true)).to eq([org1, org2])
        end
      end
    end
  end

  describe 'managed_organizations_within_market' do
    let(:org1) { create(:organization, :buyer, name: 'Org 1') }
    let(:org2) { create(:organization, :buyer, name: 'Org 2') }
    let(:org3) { create(:organization, :buyer, name: 'Org 3') }
    let(:org4) { create(:organization, :buyer, name: 'Org 4') }
    let(:org5) { create(:organization, :buyer, name: 'Org 5') }

    let!(:market1) { create(:market, organizations: [org1, org5]) }
    let!(:market2) { create(:market, organizations: [org2]) }
    let!(:market3) { create(:market, organizations: [org3, org4]) }

    context 'for an admin' do
      let(:user) { create(:user, :admin) }

      it 'returns a scope with all organizations for the market' do
        expect(user.managed_organizations_within_market(market1)).to include(org1, org5)
        expect(user.managed_organizations_within_market(market1)).to_not include(org2, org3, org4)
      end
      it 'returns a scope with all organizations not deleted for the market' do
        MarketOrganization.where(organization_id: org5.id, market_id: market1.id).first.update_attribute(:deleted_at, 1.day.ago)
        expect(user.managed_organizations_within_market(market1)).to include(org1)
        expect(user.managed_organizations_within_market(market1)).not_to include(org5)
      end

      it 'returns a scope with all organizations not_cross_selling for the market' do
        MarketOrganization.where(organization_id: org5.id, market_id: market1.id).first.update_attribute(:cross_sell_origin_market_id, true)
        expect(user.managed_organizations_within_market(market1)).to include(org1)
        expect(user.managed_organizations_within_market(market1)).not_to include(org5)
      end
    end

    context 'for a market manager' do
      let(:user) { create(:user, :market_manager, managed_markets: [market1, market2], organizations: [org4, org5]) }

      it 'returns a chainable scope' do
        expect(user.managed_organizations_within_market(market1)).to be_a_kind_of(ActiveRecord::Relation)
      end

      it 'includes organizations in the market they manage' do
        expect(user.managed_organizations_within_market(market1)).to include(org1, org5)
        expect(user.managed_organizations_within_market(market1)).to_not include(org2, org3, org4)
      end

      it 'includes their organizations in the market they do not manage' do
        expect(user.managed_organizations_within_market(market3)).to include(org4)
        expect(user.managed_organizations_within_market(market3)).to_not include(org1, org2, org3, org5)
      end
    end

    context 'for a user' do
      let(:user) { create(:user, organizations: [org1, org5]) }

      it 'returns a scope for the organization memberships within the market' do
        expect(user.managed_organizations_within_market(market1)).to include(org1, org5)
        expect(user.managed_organizations_within_market(market1)).to_not include(org2, org3, org4)
      end

      it 'returns a scope with all organizations not deleted for the market' do
        MarketOrganization.where(organization_id: org5.id, market_id: market1.id).first.update_attribute(:deleted_at, 1.day.ago)
        expect(user.managed_organizations_within_market(market1)).to include(org1)
        expect(user.managed_organizations_within_market(market1)).not_to include(org5)
      end

      it 'returns a scope with all organizations not_cross_selling for the market' do
        MarketOrganization.where(organization_id: org5.id, market_id: market1.id).first.update_attribute(:cross_sell_origin_market_id, true)
        expect(user.managed_organizations_within_market(market1)).to include(org1)
        expect(user.managed_organizations_within_market(market1)).not_to include(org5)
      end

      context 'user is suspended from an organization' do
        before do
          suspend_user(user: user, org: org1)
        end

        it 'will not return organizations a user is suspended from' do
          expect(user.managed_organizations_within_market(market1)).to include(org5)
          expect(user.managed_organizations_within_market(market1)).not_to include(org1, org3, org4)
        end
      end
    end
  end

  describe 'markets' do
    context "admin" do
      let(:user) { create(:user, :admin) }

      it 'returns all markets' do
        expect(user.markets).to eq(Market.all)
      end
    end

    context 'market manager' do
      let(:user) { create(:user, :market_manager) }
      let(:market1) { user.managed_markets.first }
      let(:market2) { create(:market) }
      let(:market3) { create(:market) }
      let(:org) { create(:organization) }

      before(:each) do
        user.organizations << org
        market2.organizations << org
      end

      it 'returns a relation object' do
        expect(user.markets).to be_kind_of(ActiveRecord::Relation)
      end

      it 'belongs to the markets they manage' do
        expect(user.markets).to include(market1)
      end

      it 'belongs to markets their organizations belong to' do
        expect(user.markets).to include(market2)
      end

      it 'does not show markets for which they are not members' do
        expect(user.markets).to_not include(market3)
      end

      context 'user is a  member of an organization which was deleted' do
        let!(:empty_market) { create(:market, organizations: [], managers: [user]) }
        let!(:deleted_organization) { create(:organization, markets: [empty_market]) }

        before do
          mo = MarketOrganization.where(market_id: empty_market.id, organization_id: deleted_organization.id)
          mo.soft_delete
        end

        it 'still returns markets the user manages' do
          expect(user.markets).to include(empty_market)
        end
      end

    end

    context 'user' do
      let(:user) { create(:user) }
      let(:market1) { create(:market) }
      let(:market2) { create(:market) }
      let(:org) { create(:organization) }

      before(:each) do
        user.organizations << org
        market1.organizations << org
      end

      it 'returns a relation object' do
        expect(user.markets).to be_kind_of(ActiveRecord::Relation)
      end

      it 'belongs to markets their organizations belong to' do
        expect(user.markets).to include(market1)
      end

      it 'does not show markets for which they are not members' do
        expect(user.markets).to_not include(market2)
      end
    end
  end

  describe 'managed_products' do
    subject { user.managed_products }

    context 'for an admin' do
      let!(:user) { create(:user, :admin) }

      xit 'returns all products' do
        Timecop.freeze do
          expect(subject).to eq(Product.visible.seller_can_sell.joins(organization: :market_organizations))
        end
      end
    end

    context 'for a market manager' do
      let!(:user) { create(:user, :market_manager) }
      let!(:market1) { user.managed_markets.first }
      let!(:market2) { create(:market) }
      let!(:org1) { create(:organization, markets: [market1]) }
      let!(:org2) { create(:organization, markets: [market2]) }
      let!(:prod1) { create(:product, organization: org1) }
      let!(:prod2) { create(:product, organization: org2) }
      let!(:deleted_prod) { create(:product, organization: org1, deleted_at: 1.minute.ago) }

      it 'returns a scope' do
        expect(subject).to be_kind_of(ActiveRecord::Relation)
      end

      it 'returned scope includes products for organizations in markets they manage' do
        expect(subject).to include(prod1)
      end

      it 'returned scope does not include products for organizations in markets they do not manage' do
        expect(subject).to_not include(prod2)
      end

      it 'returned scope does not include deleted products' do
        expect(subject).to_not include(deleted_prod)
      end
    end

    context 'for a user' do
      let!(:user) { create(:user) }
      let!(:market1) { create(:market) }
      let!(:org1) { create(:organization, markets: [market1], users: [user]) }
      let!(:org2) { create(:organization, markets: [market1]) }
      let!(:prod1) { create(:product, organization: org1) }
      let!(:prod2) { create(:product, organization: org2) }
      let!(:deleted_prod) { create(:product, organization: org1, deleted_at: 1.minute.ago) }

      it 'returns a scope' do
        expect(subject).to be_kind_of(ActiveRecord::Relation)
      end

      it 'returned scope includes products for organizations they belong to' do
        expect(subject).to include(prod1)
      end

      it 'returned scope does not include products for organization they do not belong to' do
        expect(subject).to_not include(prod2)
      end

      it 'returned scope does not include deleted products' do
        expect(subject).to_not include(deleted_prod)
      end
    end
  end

  describe 'token authentication' do
    let!(:user) { create(:user) }

    describe '#auth_token' do
      it 'returns a token string' do
        expect(user.auth_token).to be_a(String)
      end
    end

    describe '.for_auth_token' do
      it 'returns the user for a valid token' do
        expect(User.for_auth_token(user.auth_token)).to eq(user)
      end

      it 'returns nil for a blank token' do
        expect(User.for_auth_token(nil)).to be_nil
        expect(User.for_auth_token('')).to be_nil
      end

      it 'returns nil for an expired token' do
        expect(User.for_auth_token(user.auth_token(-10.minutes))).to be_nil
      end

      it 'return nil for an invalid token' do
        expect(User.for_auth_token('not-gonna-do-it')).to be_nil
      end
    end
  end

  context 'oranizations scopes' do
    let!(:market) { create(:market) }
    let!(:user) { create(:user) }
    let!(:org1) { create(:organization, users: [user], markets: [market]) }
    let!(:org2) { create(:organization, users: [user], markets: [market]) }

    describe '#organizations' do
      let(:result) { user.organizations }

      it 'returns the organizations the user belongs to' do
        expect(result.count).to eql(2)
        expect(result).to include(org1)
        expect(result).to include(org2)
      end

      context 'when the user has been suspended from an organization' do
        before do
          suspend_user(user: user, org: org1)
        end

        it 'does not return organizations where the user is suspended' do
          expect(result.count).to eql(1)
          expect(result).not_to include(org1)
          expect(result).to include(org2)
        end
      end
    end

    describe '#organizations_including_suspended' do
      let(:result) { user.organizations_including_suspended }

      before do
        suspend_user(user: user, org: org1)
      end

      context 'when the user has been suspended from an organization' do
        it 'returns all organizations a user is associated with including suspended' do
          expect(result.count).to eql(2)
          expect(result).to include(org1)
          expect(result).to include(org2)
        end
      end
    end

    describe '#suspended_organizations' do
      let(:result) { user.suspended_organizations }
      before do
        suspend_user(user: user, org: org1)
      end

      it 'returns all organizations a user is suspended from' do
        expect(result.count).to eql(1)

        expect(result).to include(org1)
        expect(result).not_to include(org2)
      end
    end
  end

  describe '.in_market scope' do
    let!(:market) { create(:market) }
    let!(:market2) { create(:market) }

    let!(:user1)  { create(:user, :buyer) }
    let!(:user2)  { create(:user, :buyer) }
    let!(:user3)  { create(:user, :supplier) }
    let!(:user4)  { create(:user) }
    let!(:user5)  { create(:user, :buyer) }

    let!(:buyer_org1)   { create(:organization, :buyer, markets: [market], users: [user1]) }
    let!(:buyer_org2)   { create(:organization, :buyer, markets: [market], users: [user2]) }
    let!(:seller_org3)   { create(:organization, :seller, markets: [market], users: [user3]) }

    let!(:buyer_org2_again) { create(:organization, :buyer, markets: [market2], users: [user2]) }
    let!(:buyer_org5) { create(:organization, :buyer, markets: [market2], users: [user5]) }

    it 'gets all the Users in a Market' do
      users = User.in_market(market)
      expect(users).to contain_exactly(user1,user2,user3)
    end

    it 'can accept an id instead of a Market instance' do
      expect(User.in_market(market.id)).to contain_exactly(user1,user2,user3)
    end

    context 'with a user only belonging to inactive organization' do
      before do
        buyer_org1.update_attribute(:active, false)
      end
      it 'does not include users from inactive orgs' do
        expect(User.in_market(market.id)).to contain_exactly(user2,user3)
      end
    end

    context 'wieth a soft deleted organization' do
      before do
        buyer_org2.market_organizations.find_by(market: market).soft_delete
      end
      it 'respects deleted organization-market links' do
        expect(User.in_market(market)).to contain_exactly(user1,user3)
      end
    end
  end

  context 'users with subscriptions' do
    let!(:user1)  { create(:user, :supplier) }
    let!(:user2)  { create(:user, :supplier) }
    let!(:user3)  { create(:user, :supplier) }
    let!(:user4)  { create(:user, :supplier) }

    let!(:ads) { create(:subscription_type, name: 'Advertisements', keyword: 'ads') }
    let!(:notes) { create(:subscription_type, name: 'Note Notices', keyword: 'notes') }

    before do
      user1.subscribe_to ads
      user2.subscribe_to ads
      user2.subscribe_to notes
      user3.subscribe_to notes
    end

    describe '.subscribed_to scope' do
      it 'includes users who are subscribed to the given subscriptio type' do
        expect(User.subscribed_to(ads)).to contain_exactly(user1,user2)
        expect(User.subscribed_to(notes)).to contain_exactly(user2,user3)
      end

      it 'accepts a subscription type keyword in lieu of SubscriptionType instance' do
        expect(User.subscribed_to('ads')).to contain_exactly(user1,user2)
        expect(User.subscribed_to('notes')).to contain_exactly(user2,user3)
      end

      it 'accepts a subscription type id in lieu of SubscriptionType instance' do
        expect(User.subscribed_to(ads.id)).to contain_exactly(user1,user2)
        expect(User.subscribed_to(notes.id)).to contain_exactly(user2,user3)
      end

      it 'respects soft-deleted subscriptions' do
        # user2 unsubscribes from ads:
        user2.subscriptions.find_by(subscription_type: ads).soft_delete
        expect(User.subscribed_to(ads)).to contain_exactly(user1)

        # user1 unsubscribes from ads:
        user1.subscriptions.find_by(subscription_type: ads).soft_delete
        expect(User.subscribed_to(ads)).to be_empty

        # user1 REsubscribes to ads:
        user1.subscriptions.find_by(subscription_type: ads).undelete
        expect(User.subscribed_to(ads)).to contain_exactly(user1)

        # Check other subs:
        expect(User.subscribed_to(notes.id)).to contain_exactly(user2,user3)
      end
    end

    describe '#subscribe_to and #unsubscribe_from' do
      it 'creates and soft-deletes links' do
        expect(User.subscribed_to(ads)).not_to include(user3)

        # subscribe to ads:
        user3.subscribe_to(ads)
        expect(User.subscribed_to(ads)).to include(user3)

        # Unsubscribe from ads:
        user3.unsubscribe_from(ads)
        expect(User.subscribed_to(ads)).not_to include(user3)

        # inspect the subscription link:
        sub = user3.subscriptions.find_by(subscription_type: ads)
        expect(sub).to be
        expect(sub.deleted_at).to be_about(Time.current)
        token = sub.token

        # Resubscribe and see the subscription come back to life:
        user3.subscribe_to(ads)
        sub.reload
        expect(sub.deleted_at).to be_nil
        expect(sub.token).to eq(token)
        expect(User.subscribed_to(ads)).to include(user3)
      end

    end

    describe '#active_subscriptions' do
      let!(:ads_sub) { user2.subscriptions.find_by(subscription_type: ads) }
      let!(:notes_sub) { user2.subscriptions.find_by(subscription_type: notes) }

      it 'returns non-deleted subscriptions' do
        ads_sub = user2.subscriptions.find_by(subscription_type: ads)
        notes_sub = user2.subscriptions.find_by(subscription_type: notes)

        expect(user2.active_subscriptions).to contain_exactly(ads_sub, notes_sub)
      end

      it 'ignores soft-deleted subscriptions' do
        ads_sub.soft_delete
        expect(user2.active_subscriptions).to contain_exactly(notes_sub)

        notes_sub.soft_delete
        expect(user2.active_subscriptions).to be_empty
      end
    end

    describe '#active_subscription_types' do
      it 'returns active subscription types' do
        expect(user2.active_subscription_types).to contain_exactly(ads,notes)
      end

      it 'ignores soft-deleted subscriptions' do
        user2.unsubscribe_from(ads)
        expect(user2.active_subscription_types).to contain_exactly(notes)

        user2.unsubscribe_from(notes)
        expect(user2.active_subscription_types).to be_empty
      end
    end
  end

  describe '.buyers scope' do
    include_context 'the fresh market'

    it 'returns all users that belong to buying orgs' do
      # NOTE: Barry's in here TWICE because he's a member of two separate Buying orgs.
      expect(User.buyers).to contain_exactly(barry,barry,bill,basil,craig,clarence)
    end

    it 'returns all users that belong to buying orgs in the given Market' do
      # Barry should still be in twice
      # OMITTED: Steve's a seller (technically he can buy but he's not JUST a buyer)
      # OMITTED: Clarence's link to Fresh Market has been soft deleted
      # OMITTED: Craig's in Other Market
      expect(User.buyers.in_market(fresh_market)).to contain_exactly(barry,barry,bill,basil)
    end
  end

  describe '.sellers scope' do
    include_context 'the fresh market'
    it 'returns users that belong to selling orgs' do
      expect(User.sellers.map(&:name)).to contain_exactly(*[basil, steve, sol, scarbro].map(&:name))
      expect(User.sellers).to contain_exactly(basil, steve, sol, scarbro)
    end

    it 'returns users that belong to selling orgs in a market' do
      # OMITTED: Sol's link is soft deleted
      # OMITTED: Scarbro's in Other Market
      expect(User.sellers.in_market(fresh_market).map(&:name)).to contain_exactly(*[steve, basil].map(&:name))
      expect(User.sellers.in_market(fresh_market)).to contain_exactly(basil, steve)
    end
  end

  describe 'default subscriptions' do
    include_context 'fresh sheet and newsletter subscription types'
    it 'will be Fresh Sheet and Newsletter' do
      user = User.create!(email:'a@a.a', password:'abcd1234',password_confirmation:'abcd1234')
      expect(user.active_subscription_types).to contain_exactly(fresh_sheet_subscription_type, newsletter_subscription_type)
    end

    it 'will not be installed if User is explicitly built with other subscription types' do
      my_sub_type = create(:subscription_type, name: 'Custom type')
      user = User.create!(subscription_types: [my_sub_type], email:'a@a.a', password:'abcd1234',password_confirmation:'abcd1234')
      expect(user.active_subscription_types).to contain_exactly(my_sub_type)
    end
  end
  describe '#unsubscribe_token' do
    include_context 'fresh sheet and newsletter subscription types'
    let!(:user) { create(:user) }
    it 'gets the token from the Subscription associated with the given SubscriptionType' do
      tolkein = user.unsubscribe_token(subscription_type: fresh_sheet_subscription_type)
      expect(tolkein).to eq(user.subscriptions.find_by(subscription_type: fresh_sheet_subscription_type).token)
    end
  end

  describe '#default_market' do
    let(:buyer_org1) { create(:organization, :buyer, name: 'Buyer Org 1') }

    let(:supplier_org_inactive_newer) { create(:organization, :seller, name: 'Inactive Supplier Org 1 (Newer)', active: false) }
    let(:supplier_org_inactive_older) { create(:organization, :seller, name: 'Inactive Supplier Org 2 (Oldest)', active: false, created_at: 1.year.ago) }

    let(:supplier_org1) { create(:organization, :seller, name: 'Supplier Org 1 (Newer)') }
    let(:supplier_org2) { create(:organization, :seller, name: 'Supplier Org 2 (Older)', created_at: 2.months.ago) }
    let(:supplier_org3) { create(:organization, :seller, name: 'Supplier Org 3 (Oldest)', created_at: 3.years.ago) }

    let!(:market_inactive1) { create(:market, name: 'Inactive Market 1', organizations: [buyer_org1, supplier_org1], active: false) }
    let!(:market_inactive2) { create(:market, name: 'Inactive Market 2', organizations: [buyer_org1, supplier_org1, supplier_org2], active: false) }

    let!(:market_active1) { create(:market, name: 'Active Market 1', organizations: [buyer_org1, supplier_org1, supplier_org_inactive_newer]) }
    let!(:market_active2) { create(:market, name: 'Active Market 2', organizations: [buyer_org1, supplier_org3, supplier_org_inactive_older]) }

    context 'as an admin' do
      let(:admin_org) { create(:organization, :admin) }
      let(:admin) { create(:user, :admin, organizations: [admin_org]) }

      context 'and the admin market exists' do
        let!(:admin_market) { create(:market, subdomain: "admin") }

        it 'returns the admin market' do
           expect(admin.default_market).to eq(admin_market)
        end
      end

      context 'but the admin market does not exist' do
        it 'returns nil' do
          expect(admin.default_market).to be_nil
        end
      end
    end

    context 'as a market manager' do
      let(:market_manager) { create(:user, :market_manager, managed_markets: managed_markets) }

      context 'who manages active and inactive markets' do
        let(:managed_markets) { [market_inactive1, market_active1, market_inactive2] }

        it 'returns the first active market' do
          expect(market_manager.default_market).to eq(market_active1)
        end
      end

      context 'who manages only an inactive market' do
        let(:managed_markets) { [market_inactive1] }

        it 'returns nil' do
          expect(market_manager.default_market).to be_nil
        end
      end
    end

    context 'as a supplier' do
      let(:supplier) { create(:user, :supplier, organizations: organizations) }

      context 'who belongs to an active organization' do
        context 'in both an active and inactive market' do
          let(:organizations) { [supplier_org1, supplier_org3] }

          it 'returns the market associated with the most recently created active organization' do
            expect(supplier.default_market).to eq(market_active1)
          end
        end

        context 'in an inactive market' do
          let(:organizations) { [supplier_org2] }

          it 'returns nil' do
            expect(supplier.default_market).to be_nil
          end
        end
      end

      context 'who belongs to two inactive organizations in separate active markets' do
        let(:organizations) { [supplier_org_inactive_older, supplier_org_inactive_newer] }

        it 'returns the market associated with the most recently created inactive organization' do
          expect(supplier.default_market).to eq(market_active1)
        end
      end
    end
  end
end
