require 'spec_helper'

describe 'Filter organizations', :js do
  let!(:empty_market) { create(:market) }

  let!(:market1)      { create(:market) }
  let!(:org1)         { create(:organization, :seller, markets: [market1]) }
  let!(:org1_product) { create(:product, :sellable, organization: org1) }
  let!(:org2)         { create(:organization, :buyer, markets: [market1]) }

  let!(:market2)      { create(:market) }
  let!(:org3)         { create(:organization, :seller, markets: [market2]) }
  let!(:org3_product) { create(:product, :sellable, organization: org3) }
  let!(:org4)         { create(:organization, :buyer, markets: [market2]) }

  context 'as an admin' do
    let!(:user) { create(:user, role: 'admin') }

    before do
      sign_in_as(user)
      visit admin_organizations_path
    end

    context 'by market' do
      it 'shows an empty state' do
        select empty_market.name, from: "filter_market"

        expect(page).to have_content("No Results")
      end

      it 'shows all markets when unfiltered' do
        expect(page).to have_content(org1.name)
        expect(page).to have_content(org2.name)
        expect(page).to have_content(org3.name)
        expect(page).to have_content(org4.name)
      end

      it 'shows organizations for only the selected market' do
        select market1.name, from: "filter_market"

        expect(page).to have_content(org1.name)
        expect(page).to have_content(org2.name)

        expect(page).to_not have_content(org3.name)
        expect(page).to_not have_content(org4.name)
      end
    end

    context 'by can sell' do
      it 'shows all markets when unfiltered' do
        expect(page).to have_content(org1.name)
        expect(page).to have_content(org2.name)
        expect(page).to have_content(org3.name)
        expect(page).to have_content(org4.name)
      end

      it 'shows organizations that can sell' do
        select "Can Sell", from: "filter_can_sell"

        expect(page).to have_content(org1.name)
        expect(page).to have_content(org3.name)
        expect(page).to_not have_content(org2.name)
        expect(page).to_not have_content(org4.name)
      end
    end

    context "by name" do
      it "shows markets by searched string" do
        expect(Dom::Admin::OrganizationRow.count).to eq(4)

        fill_in "search", with: org1.name
        click_button "Search"

        expect(Dom::Admin::OrganizationRow.count).to eq(1)
        expect(Dom::Admin::OrganizationRow.first.name).to eq(org1.name)
      end
    end
  end

  context 'as a market manager' do
    let!(:market3) { create(:market) }
    let!(:org5) { create(:organization, :seller, markets: [market3]) }

    let!(:user) { create(:user, role: 'user', managed_markets: [market1, market3, empty_market]) }

    before do
      switch_to_subdomain(market1.subdomain)
      sign_in_as(user)
      visit admin_organizations_path
    end

    context 'by market' do
      it 'shows an empty state' do
        select empty_market.name, from: "filter_market"

        expect(page).to have_content("No Results")
      end

      it 'shows all managed markets when unfiltered' do
        expect(page).to have_content(org1.name)
        expect(page).to have_content(org2.name)
        expect(page).to have_content(org5.name)
        expect(page).to_not have_content(org3.name)
        expect(page).to_not have_content(org4.name)
      end

      it 'shows organizations for only the selected market' do
        select market3.name, from: "filter_market"

        expect(page).to have_content(org5.name)

        expect(page).to_not have_content(org1.name)
        expect(page).to_not have_content(org2.name)
        expect(page).to_not have_content(org3.name)
        expect(page).to_not have_content(org4.name)
      end
    end


    context 'by can sell' do
      it 'shows all markets when unfiltered' do
        expect(page).to have_content(org1.name)
        expect(page).to have_content(org2.name)
        expect(page).to have_content(org5.name)
        expect(page).to_not have_content(org3.name)
        expect(page).to_not have_content(org4.name)
      end

      it 'shows organizations that can sell' do
        select "Can Sell", from: "filter_can_sell"

        expect(page).to have_content(org1.name)
        expect(page).to have_content(org5.name)
        expect(page).to_not have_content(org2.name)
        expect(page).to_not have_content(org3.name)
        expect(page).to_not have_content(org4.name)
      end
    end
  end
end
