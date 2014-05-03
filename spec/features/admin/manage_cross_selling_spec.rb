require 'spec_helper'

describe "Manage cross selling" do
  let!(:user) { create(:user, role: 'admin') }

  let!(:cross_selling_market)     { create(:market, allow_cross_sell: true) }
  let!(:not_cross_selling_market) { create(:market)}

  context 'for a none-cross selling market' do
    let!(:market) { create(:market) }
    let!(:organization) { create(:organization, :seller, markets: [market]) }

    context 'managing a market' do
      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as user
        visit admin_market_path(market)
      end

      it "does not show the cross-sell tab" do
        expect(page).to_not have_css(".tabs", text: 'Cross Sell')
      end
    end

    context "managing an organization" do
      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as user
        visit admin_organization_path(organization)
      end

      it "does not show the cross-sell tab" do
        expect(page).to_not have_css(".tabs", text: 'Cross Sell')
      end
    end
  end

  context 'for a cross selling market' do
    let!(:market) { create(:market, allow_cross_sell: true) }
    let!(:organization) { create(:organization, :seller, markets: [market]) }

    context 'managing a market' do
      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as user
        visit admin_market_path(market)
      end

      it "does show the cross-sell tab" do
        expect(page).to have_css(".tabs", text: 'Cross Sell')
      end

      it "shows a list of cross selling markets" do
        within ".tabs" do
          click_link "Cross Sell"
        end

        expect(page).to have_content(cross_selling_market.name)
        expect(page).to_not have_content(not_cross_selling_market.name)
      end

      it "saves changes to cross selling markets" do
        within ".tabs" do
          click_link "Cross Sell"
        end

        market_row = Dom::Admin::CrossSell.find_by_name(cross_selling_market.name)
        expect(market_row).to_not be_checked

        market_row.check

        click_button "Save Changes"

        expect(page).to have_content("Market Updated Successfully")

        market_row = Dom::Admin::CrossSell.find_by_name(cross_selling_market.name)
        expect(market_row).to be_checked

        market_row.uncheck

        click_button "Save Changes"

        expect(page).to have_content("Market Updated Successfully")

        market_row = Dom::Admin::CrossSell.find_by_name(cross_selling_market.name)
        expect(market_row).to_not be_checked
      end
    end

    context "managing an organization" do
      before do
        market.cross_sells << cross_selling_market

        switch_to_subdomain(market.subdomain)
        sign_in_as user
        visit admin_organization_path(organization)
      end

      it "does show the cross-sell tab" do
        expect(page).to have_css(".tabs", text: 'Cross Sell')
      end

      it "shows a list of cross selling markets" do
        within ".tabs" do
          click_link "Cross Sell"
        end

        expect(page).to have_content(cross_selling_market.name)
        expect(page).to_not have_content(not_cross_selling_market.name)
      end

      it "saves changes to cross selling markets" do
        within ".tabs" do
          click_link "Cross Sell"
        end

        organization_row = Dom::Admin::CrossSell.find_by_name(cross_selling_market.name)
        expect(organization_row).to_not be_checked

        organization_row.check

        click_button "Save Changes"

        expect(page).to have_content("Organization Updated Successfully")

        organization_row = Dom::Admin::CrossSell.find_by_name(cross_selling_market.name)
        expect(organization_row).to be_checked

        organization_row.uncheck

        click_button "Save Changes"

        expect(page).to have_content("Organization Updated Successfully")

        organization_row = Dom::Admin::CrossSell.find_by_name(cross_selling_market.name)
        expect(organization_row).to_not be_checked
      end
    end
  end
end
