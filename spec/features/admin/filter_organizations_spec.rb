require 'spec_helper'

describe 'Filter organizations', :js do
  context 'by market' do
    let!(:user) { create(:user, role: 'admin') }

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

    before do
      sign_in_as(user)
      visit admin_organizations_path
    end

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
