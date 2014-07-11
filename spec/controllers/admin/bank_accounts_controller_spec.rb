require 'spec_helper'

describe Admin::BankAccountsController, :vcr do
  let!(:market)                   { create(:market) }
  let(:admin)                     { create(:user, :admin) }
  let(:market_manager_member)     { create(:user, managed_markets: [market]) }
  let(:market_manager_non_member) { create(:user, :market_manager) }
  let(:organization)              { create(:organization, :seller, markets: [market]) }
  let(:member)                    { create(:user, organizations: [organization]) }
  let(:non_member)                { create(:user) }
  describe "bank accounts" do
    let(:balanced_uri) do
      Balanced::BankAccount.new(
        routing_number: '021000021',
        account_number: '9900000002',
        name: 'Johann Bernoulli',
        type: 'checking'
      ).save.uri
    end

    let(:valid_params) do
      {
        type: "checking",
        bank_account: {
          name: "Org Bank Account",
          last_four: "0002",
          balanced_uri: balanced_uri,
          account_type: "checking",
          expiration_month: "",
          expiration_year: "",
          notes: "Primary"
        },
        representative: {
          name: "John Patrick Doe",
          ein: "20-1234567",
          dob: {
            month: "8",
            day: "17",
            year: "1990"
          },
          ssn_last4: "1234",
          address: {
            line1: "6789 Fake Dr",
            postal_code: "12345"
          }
        }
      }
    end

    before do
      switch_to_subdomain market.subdomain
    end

    context "for market" do
      before do
        CreateBalancedCustomerForEntity.perform(market: market)
      end

      describe "#index" do
        it_behaves_like "an action restricted to admin or market manager", lambda { get :index, market_id: market.id }
      end

      describe "#new" do
        it_behaves_like "an action restricted to admin or market manager", lambda { get :new, market_id: market.id }
      end

      describe "#create" do
        it_behaves_like "an action restricted to admin or market manager", lambda { post :create, {market_id: market.id}.merge(valid_params) }
      end

      describe "#destroy" do
        let(:bank_account) { create(:bank_account, :checking, bankable: market) }
        it_behaves_like "an action restricted to admin or market manager", lambda { delete :destroy, {market_id: market.id, id: bank_account.id} }
      end
    end

    context "for seller organization" do
      before do
        CreateBalancedCustomerForEntity.perform(organization: organization)
      end

      describe "#index" do
        it_behaves_like "an action restricted to admin, market manager, member", lambda { get :index, organization_id: organization.id }
      end

      describe "#new" do
        it_behaves_like "an action restricted to admin, market manager, member", lambda { get :index, organization_id: organization.id }
      end

      describe "#create" do
        it_behaves_like "an action restricted to admin, market manager, member", lambda { post :create, {organization_id: organization.id}.merge(valid_params) }
      end

      describe "#destroy" do
        let(:bank_account) { create(:bank_account, :checking, bankable: organization) }
        it_behaves_like "an action restricted to admin, market manager, member", lambda { delete :destroy, {organization_id: organization.id, id: bank_account.id} }
      end
    end

    context "for buyer organization" do
      let(:organization) { create(:organization, :buyer, markets: [market]) }

      before do
        CreateBalancedCustomerForEntity.perform(organization: organization)
      end

      describe "#index" do
        it_behaves_like "an action restricted to admin, market manager, member", lambda { get :index, organization_id: organization.id }
      end

      describe "#new" do
        it_behaves_like "an action restricted to admin, market manager, member", lambda { get :index, organization_id: organization.id }
      end

      describe "#create" do
        it_behaves_like "an action restricted to admin, market manager, member", lambda { post :create, {organization_id: organization.id}.merge(valid_params) }
      end

      describe "#destroy" do
        let(:bank_account) { create(:bank_account, :checking, bankable: organization) }
        it_behaves_like "an action restricted to admin, market manager, member", lambda { delete :destroy, {organization_id: organization.id, id: bank_account.id} }
      end
    end
  end

  describe "credit cards" do
    let(:balanced_uri) do
      Balanced::Card.new(
        uri: "#{ENV["BALANCED_MARKETPLACE_URI"]}/cards",
        name: "John Doe",
        card_number: "4111111111111111",
        expiration_month: "05",
        expiration_year: "2020",
        security_code: "123"
      ).save.uri
    end

    let(:valid_params) do
      {
        type: "card",
        bank_account: {
          name: "John Doe",
          last_four: "1111",
          balanced_uri: balanced_uri,
          account_type: "visa",
          expiration_month: "5",
          expiration_year: "2020",
          notes: ""
        }
      }
    end

    before do
      switch_to_subdomain market.subdomain
    end

    context "for market" do
      before do
        CreateBalancedCustomerForEntity.perform(market: market)
      end

      describe "#index" do
        it_behaves_like "an action restricted to admin or market manager", lambda { get :index, market_id: market.id }
      end

      describe "#new" do
        it_behaves_like "an action restricted to admin or market manager", lambda { get :new, market_id: market.id }
      end

      describe "#create" do
        it_behaves_like "an action restricted to admin or market manager", lambda { post :create, {market_id: market.id}.merge(valid_params) }
      end

      describe "#destroy" do
        let(:credit_card) { create(:bank_account, :credit_card, bankable: market) }
        it_behaves_like "an action restricted to admin or market manager", lambda { delete :destroy, {market_id: market.id, id: credit_card.id} }
      end
    end

    context "for seller organization" do
      before do
        CreateBalancedCustomerForEntity.perform(organization: organization)
      end

      describe "#index" do
        it_behaves_like "an action restricted to admin, market manager, member", lambda { get :index, organization_id: organization.id }
      end

      describe "#new" do
        it_behaves_like "an action restricted to admin, market manager, member", lambda { get :index, organization_id: organization.id }
      end

      describe "#create" do
        it_behaves_like "an action restricted to admin, market manager, member", lambda { post :create, {organization_id: organization.id}.merge(valid_params) }
      end

      describe "#destroy" do
        let(:credit_card) { create(:bank_account, :credit_card, bankable: organization) }
        it_behaves_like "an action restricted to admin, market manager, member", lambda { delete :destroy, {organization_id: organization.id, id: credit_card.id} }
      end
    end

    context "for buyer organization" do
      let(:organization) { create(:organization, :buyer, markets: [market]) }

      before do
        CreateBalancedCustomerForEntity.perform(organization: organization)
      end

      describe "#index" do
        it_behaves_like "an action restricted to admin, market manager, member", lambda { get :index, organization_id: organization.id }
      end

      describe "#new" do
        it_behaves_like "an action restricted to admin, market manager, member", lambda { get :index, organization_id: organization.id }
      end

      describe "#create" do
        it_behaves_like "an action restricted to admin, market manager, member", lambda { post :create, {organization_id: organization.id}.merge(valid_params) }
      end

      describe "#destroy" do
        let(:credit_card) { create(:bank_account, :credit_card, bankable: organization) }
        it_behaves_like "an action restricted to admin, market manager, member", lambda { delete :destroy, {organization_id: organization.id, id: credit_card.id} }
      end
    end
  end
end
