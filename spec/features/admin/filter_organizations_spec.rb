require "spec_helper"

describe "Filter organizations", :js do
  let!(:empty_market) { create(:market) }

  let!(:market1)      { create(:market) }
  let!(:org1)         { create(:organization, :seller, markets: [market1]) }
  let!(:org1_product) { create(:product, :sellable, organization: org1) }
  let!(:org2)         { create(:organization, :buyer, markets: [market1]) }

  let!(:market2)      { create(:market) }
  let!(:org3)         { create(:organization, :seller, markets: [market2]) }
  let!(:org3_product) { create(:product, :sellable, organization: org3) }
  let!(:org4)         { create(:organization, :buyer, markets: [market2]) }

  context "as an admin", :js do
    let!(:user) { create(:user, role: "admin") }

    context "by market" do
      before do
        sign_in_as(user)
        visit admin_organizations_path
      end

      it "shows all markets when unfiltered" do
        expect(page).to have_content(org1.name)
        expect(page).to have_content(org2.name)
        expect(page).to have_content(org3.name)
        expect(page).to have_content(org4.name)
      end

      it "shows organizations for only the selected market" do
        select market1.name, from: "filter_market"

        expect(page).to have_content(org1.name)
        expect(page).to have_content(org2.name)

        expect(page).to_not have_content(org3.name)
        expect(page).to_not have_content(org4.name)
        unselect market1.name, from: "filter_market"

      end
    end

    context "by can sell", :js do
      before do
        sign_in_as(user)
        visit admin_organizations_path
      end

      it "shows all markets when unfiltered" do
        expect(page).to have_content(org1.name)
        expect(page).to have_content(org2.name)
        expect(page).to have_content(org3.name)
        expect(page).to have_content(org4.name)
      end

      it "shows organizations that can sell" do
        select "Supplier", from: "filter_can_sell"

        expect(page).to have_content(org1.name)
        expect(page).to have_content(org3.name)
        expect(page).to_not have_content(org2.name)
        expect(page).to_not have_content(org4.name)
        unselect "Supplier", from: "filter_can_sell"

      end
    end

    context "by name" do
      before do
        sign_in_as(user)
        visit admin_organizations_path
      end

      it "shows markets by searched string" do
        expect(Dom::Admin::OrganizationRow.count).to eq(4)

        fill_in "search", with: org1.name
        click_button "Search"

        expect(Dom::Admin::OrganizationRow.count).to eq(1)
        expect(Dom::Admin::OrganizationRow.first.name).to eq(org1.name)
      end
    end
  end

  context "as a market manager" do
    let!(:market3) { create(:market) }
    let!(:org5) { create(:organization, :seller, markets: [market3]) }

    let!(:market_manager) { create(:user, role: "user", managed_markets: [market1, market3, empty_market]) }

    context "by market" do
      context "when the market manager only manages a single organization" do
        let!(:single_market_manager) { create(:user, role: "user", managed_markets: [market1]) }

        it "does not show the market filter" do
          switch_to_subdomain(market1.subdomain)
          sign_in_as(single_market_manager)
          visit admin_organizations_path

          expect(page).not_to have_selector("Market")
        end
      end

      context "when the market manager manages multiple organizations" do
        before do
          switch_to_subdomain(market1.subdomain)
          sign_in_as(market_manager)
          visit admin_organizations_path
        end

        it "shows all managed markets when unfiltered" do
          expect(page).to have_content(org1.name)
          expect(page).to have_content(org2.name)
          expect(page).to have_content(org5.name)
          expect(page).to_not have_content(org3.name)
          expect(page).to_not have_content(org4.name)
        end

        it "shows organizations for only the selected market" do
          select market3.name, from: "filter_market"

          expect(page).to have_content(org5.name)

          expect(page).to_not have_content(org1.name)
          expect(page).to_not have_content(org2.name)
          expect(page).to_not have_content(org3.name)
          expect(page).to_not have_content(org4.name)
          unselect market3.name, from: "filter_market"

        end
      end
    end

    context "by can sell" do
      before do
        switch_to_subdomain(market1.subdomain)
        sign_in_as(market_manager)
        visit admin_organizations_path
      end

      it "shows all markets when unfiltered" do
        expect(page).to have_content(org1.name)
        expect(page).to have_content(org2.name)
        expect(page).to have_content(org5.name)
        expect(page).to_not have_content(org3.name)
        expect(page).to_not have_content(org4.name)
      end

      it "shows organizations that can sell" do
        select "Supplier", from: "filter_can_sell"

        expect(page).to have_content(org1.name)
        expect(page).to have_content(org5.name)
        expect(page).to_not have_content(org2.name)
        expect(page).to_not have_content(org3.name)
        expect(page).to_not have_content(org4.name)
        unselect "Supplier", from: "filter_can_sell"

      end
    end
  end
end
