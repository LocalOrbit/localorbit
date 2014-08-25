require "spec_helper"

describe "Plan Limits" do
  let(:plan)    { create(:plan) }
  let!(:market) { create(:market, plan: plan) }
  let!(:user)   { create(:user, managed_markets: [market]) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  context "on the startup plan" do
    let!(:plan) { create(:plan, discount_codes: false, promotions: false, custom_branding: false, cross_selling: false) }
    it "is not allowed to use discount codes" do
      within("#admin-nav") do
        expect(page).to_not have_content("Discount Codes")
      end
    end

    it "is not allowed to use feature promotions" do
      within("#admin-nav") do
        expect(page).to_not have_content("Featured Promotions")
      end
    end

    it "is not allowed to use the style chooser" do
      visit admin_market_path(market)

      expect(page).to_not have_content("Style Chooser")
    end

    it "is not allowed to use cross selling" do
      visit admin_market_path(market)

      expect(page).to_not have_content("Cross Sell")
    end

    it "is not allowed to use advanced pricing"
    it "is not allowed to use advanced inventory"

  end
end
