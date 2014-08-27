require "spec_helper"

describe Admin::DeliverySchedulesController do
  let(:organization)              { create(:organization) }
  let(:admin)                     { create(:user, :admin) }
  let(:non_member)                { create(:user) }
  let(:market_manager_non_member) { create(:user, :market_manager) }
  let(:member)                    { create(:user, organizations: [organization]) }
  let(:market_manager_member)     { create(:user, :market_manager) }
  let!(:market) do
    market_manager_member.managed_markets.first.tap do |market|
      market.organizations << organization
    end
  end

  before do
    switch_to_subdomain market.subdomain
  end

  it_behaves_like "an action restricted to admin or market manager", lambda { get :index, market_id: market.id }
  it_behaves_like "an action restricted to admin or market manager", lambda { get :new, market_id: market.id }
  it_behaves_like "an action restricted to admin or market manager", lambda { post :create, market_id: market.id, delivery_schedule: attributes_for(:delivery_schedule) }

  context "existing" do
    let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
    it_behaves_like "an action restricted to admin or market manager", lambda { get :edit, market_id: market.id, id: delivery_schedule.id }
    it_behaves_like "an action restricted to admin or market manager", lambda { patch :update, market_id: market.id, id: delivery_schedule.id, delivery_schedule: attributes_for(:delivery_schedule).merge(order_cutoff: "12") }
    it_behaves_like "an action restricted to admin or market manager", lambda { delete :destroy, market_id: market.id, id: delivery_schedule.id }
  end
end
