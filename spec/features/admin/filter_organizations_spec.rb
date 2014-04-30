require 'spec_helper'

describe 'Filter organizations', :js do


  let!(:market1) { create(:market) }
  let!(:org1) { create(:organization, :seller, markets: [market1]) }
  let!(:org1_product) { create(:product, :sellable, organization: org1) }
  let!(:org2) { create(:organization, :seller, markets: [market1]) }
  let!(:org2_product) { create(:product, :sellable, organization: org2) }

  let!(:market2) { create(:market) }
  let!(:org3) { create(:organization, :seller, markets: [market2]) }
  let!(:org3_product) { create(:product, :sellable, organization: org3) }
  let!(:org4) { create(:organization, :seller, markets: [market2]) }
  let!(:org4_product) { create(:product, :sellable, organization: org4) }

  context 'as an admin' do
    let!(:user) { create(:user, role: 'admin') }

    before do
      sign_in_as(user)
      visit admin_organizations_path
    end

    context 'by market' do
      it 'shows all markets when unfiltered' do
        expect(page).to have_content(org1.name)
        expect(page).to have_content(org2.name)
        expect(page).to have_content(org3.name)
        expect(page).to have_content(org4.name)
      end

      it 'shows organizations for selected market' do
        select market1.name, from: "filter_market"

        expect(page).to have_content(org1.name)
        expect(page).to have_content(org2.name)
      end

      it 'does not show organizations not in the selected market' do
        select market1.name, from: "filter_market"

        expect(page).to_not have_content(org3.name)
        expect(page).to_not have_content(org4.name)
      end
    end
  end

  context 'as a market manager' do
    let!(:market3) { create(:market) }
    let!(:org5) { create(:organization, :seller, markets: [market3]) }
    let!(:org5_product) { create(:product, :sellable, organization: org5) }

    let!(:user) { create(:user, role: 'user', managed_markets: [market1, market3]) }

    before do
      switch_to_subdomain(market1.subdomain)
      sign_in_as(user)
      visit admin_organizations_path
    end

    context 'by market' do
      it 'shows all managed markets when unfiltered' do
        expect(page).to have_content(org1.name)
        expect(page).to have_content(org2.name)
        expect(page).to have_content(org5.name)
        expect(page).to_not have_content(org3.name)
        expect(page).to_not have_content(org4.name)
      end

      it 'shows organizations for selected market' do
        select market3.name, from: "filter_market"

        expect(page).to have_content(org5.name)
      end

      it 'does not show organizations not in the selected market' do
        select market3.name, from: "filter_market"

        expect(page).to_not have_content(org1.name)
        expect(page).to_not have_content(org2.name)
        expect(page).to_not have_content(org3.name)
        expect(page).to_not have_content(org4.name)
      end
    end
  end
end
