require "spec_helper"

describe "Manage cross selling" do
  let!(:user) { create(:user, :market_manager) }

  let!(:cross_selling_market)     { create(:market, allow_cross_sell: true) }
  let!(:not_cross_selling_market) { create(:market) }

  context "for a none-cross selling market" do
    let!(:market) { create(:market) }
    let!(:organization) { create(:organization, :seller, markets: [market]) }

    context "managing a market" do
      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as user
        visit admin_market_path(market)
      end

      it "does not show the cross-sell tab" do
        expect(page).to_not have_css(".tabs", text: "Cross Sell")
      end
    end

    context "managing an organization" do
      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as user
        visit admin_organization_path(organization)
      end

      it "does not show the cross-sell tab" do
        expect(page).to_not have_css(".tabs", text: "Cross Sell")
      end
    end
  end

  context "for a cross selling market" do
    let!(:market) { create(:market, allow_cross_sell: true) }
    let!(:organization) { create(:organization, :seller, markets: [market]) }

    context "managing a market" do
      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as user
        visit admin_market_path(market)
      end

      it "does show the cross-sell tab" do
        expect(page).to have_css(".tabs", text: "Cross Sell")
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
      let!(:cross_selling_market2) { create(:market, allow_cross_sell: true) }
      let!(:cross_selling_market3) { create(:market, allow_cross_sell: true) }
      let!(:another_origin_market) { create(:market) }

      before do
        market.cross_sells.concat(cross_selling_market, cross_selling_market2, cross_selling_market3)
        organization.update_cross_sells!(
          from_market: market,
          to_ids:      [cross_selling_market.id, cross_selling_market2.id]
        )
        organization.update_cross_sells!(
          from_market: another_origin_market,
          to_ids:      [cross_selling_market.id, cross_selling_market2.id, cross_selling_market3.id]
        )

        switch_to_subdomain(market.subdomain)
        sign_in_as user
        visit admin_organization_path(organization)
      end

      it "does show the cross-sell tab" do
        expect(page).to have_css(".tabs", text: "Cross Sell")
      end

      it "shows a list of cross selling markets" do
        within ".tabs" do
          click_link "Cross Sell"
        end

        expect(page).to have_content(cross_selling_market.name)
        expect(page).to have_content(cross_selling_market2.name)
        expect(page).to have_content(cross_selling_market3.name)
        expect(page).to_not have_content(not_cross_selling_market.name)
      end

      it "saves changes to cross selling markets" do
        within ".tabs" do
          click_link "Cross Sell"
        end

        cross_sell_row = Dom::Admin::CrossSell.find_by_name(cross_selling_market.name)
        expect(cross_sell_row).to be_checked

        cross_sell_row2 = Dom::Admin::CrossSell.find_by_name(cross_selling_market2.name)
        expect(cross_sell_row2).to be_checked

        cross_sell_row3 = Dom::Admin::CrossSell.find_by_name(cross_selling_market3.name)
        expect(cross_sell_row3).not_to be_checked

        cross_sell_row2.uncheck
        cross_sell_row3.check

        click_button "Save Changes"

        expect(page).to have_content("Organization Updated Successfully")

        cross_sell_row = Dom::Admin::CrossSell.find_by_name(cross_selling_market.name)
        expect(cross_sell_row).to be_checked

        cross_sell_row2 = Dom::Admin::CrossSell.find_by_name(cross_selling_market2.name)
        expect(cross_sell_row2).to_not be_checked

        cross_sell_row3 = Dom::Admin::CrossSell.find_by_name(cross_selling_market3.name)
        expect(cross_sell_row3).to be_checked

        expect(organization.market_organizations.where(cross_sell_origin_market: another_origin_market).count).to eq(3)
        # if we don"t handle string keys correctly then we will create an extra join record:
        expect(organization.market_organizations.where(cross_sell_origin_market: market, deleted_at: nil).count).to eq(2)
      end
    end
  end
end
