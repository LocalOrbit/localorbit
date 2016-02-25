require "spec_helper"

describe "Manage sellers edit orders" do
  let!(:user) { create(:user, :market_manager) }
  let(:grow_plan) {create(:plan, :grow)}
  let(:start_up_plan) {create(:plan, :start_up)}

  let!(:sellers_org)                    { create(:organization, :market, plan: grow_plan)}
  let!(:sellers_edit_orders_market)     { create(:market, organization: sellers_org, managers: [user], sellers_edit_orders: false) }

  let!(:not_sellers_org)                { create(:organization, :market, plan: start_up_plan)}
  let!(:not_sellers_edit_orders_market) { create(:market, organization: not_sellers_org, managers: [user], sellers_edit_orders: false) }

  context "for a non-sellers edit orders plan" do

    before do
      switch_to_subdomain(not_sellers_edit_orders_market.subdomain)
      sign_in_as user
      visit admin_market_path(not_sellers_edit_orders_market)
    end

    it "does not display sellers edit orders as an option in the market" do
      expect(page).to_not have_css("#app-sellers-edit-orders-input")
    end

  end

  context "for a sellers edit orders plan" do
    before do
      switch_to_subdomain(sellers_edit_orders_market.subdomain)
      sign_in_as user
      visit admin_market_path(sellers_edit_orders_market)
    end

    it "saves changes to sellers edit orders markets" do

      input = find("#app-sellers-edit-orders-input")
      expect(input).to_not be_checked

      input.set(true)

      click_button "Update Market"
      visit admin_market_path(sellers_edit_orders_market)
      expect(input).to be_checked
    end
  end
end
