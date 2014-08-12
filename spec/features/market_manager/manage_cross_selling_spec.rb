require "spec_helper"

describe "Manage cross selling" do
  let!(:user) { create(:user, role: "user") }

  let!(:cross_selling_market)     { create(:market, managers: [user], allow_cross_sell: true) }
  let!(:not_cross_selling_market) { create(:market, managers: [user]) }

  context "for a none-cross selling market" do
    let!(:market) { create(:market, managers: [user]) }

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as user
      visit admin_market_path(market)
    end

    it "does not show the cross-sell tab" do
      expect(page).to_not have_css(".tabs", text: "Cross Sell")
    end

  end

  context "for a cross selling market" do
    let!(:cross_selling_market2) { create(:market, allow_cross_sell: true, managers: [user]) }
    let!(:cross_selling_market3) { create(:market, allow_cross_sell: true) }

    before do
      switch_to_subdomain(cross_selling_market.subdomain)
      sign_in_as user
      visit admin_market_path(cross_selling_market)
    end

    it "shows the cross-sell tab" do
      expect(page).to have_css(".tabs", text: "Cross Sell")
    end

    it "shows a list of cross selling markets" do
      within ".tabs" do
        click_link "Cross Sell"
      end

      expect(page).to have_content(cross_selling_market.name)
      expect(page).to have_content(cross_selling_market2.name)
      expect(page).to_not have_content(cross_selling_market3.name)
      expect(page).to_not have_content(not_cross_selling_market.name)
    end

    it "saves changes to cross selling markets" do
      visit admin_market_cross_sell_path(cross_selling_market)

      market_row = Dom::Admin::CrossSell.find_by_name(cross_selling_market2.name)
      expect(market_row).to_not be_checked

      market_row.check

      click_button "Save Changes"

      expect(page).to have_content("Market Updated Successfully")

      market_row = Dom::Admin::CrossSell.find_by_name(cross_selling_market2.name)
      expect(market_row).to be_checked
    end
  end

  context "view organization cross sells" do
    let!(:organization) { create(:organization, markets: [cross_selling_market]) }

    before do
      switch_to_subdomain(cross_selling_market.subdomain)
      sign_in_as user
      visit admin_organization_path(organization)
    end

    it "allows organization to see their cross sells" do
      click_link "Cross Sell"

      expect(page).to have_content("Cross Selling with Markets")
    end
  end
end
