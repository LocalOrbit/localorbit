require 'spec_helper'
require 'support/multiselect_helpers'

RSpec.configure do |c|
  c.include MultiselectHelpers
end

describe 'Filter products', :js do
  let!(:empty_market) { create(:market, :with_delivery_schedule) }
  let!(:market1)      { create(:market, :with_delivery_schedule) }
  let!(:org1)         { create(:organization, :seller, markets: [market1]) }
  let!(:org1_product) { create(:product, :sellable, organization: org1) }
  let!(:org2)         { create(:organization, :seller, markets: [market1]) }
  let!(:org2_product) { create(:product, :sellable, organization: org2) }

  let!(:market2)      { create(:market, :with_delivery_schedule) }
  let!(:org3)         { create(:organization, :seller, markets: [market2]) }
  let!(:org3_product) { create(:product, :sellable, organization: org3) }
  let!(:org4)         { create(:organization, :seller, markets: [market2]) }
  let!(:org4_product) { create(:product, :sellable, organization: org4) }
  let!(:org5)         { create(:organization, :buyer, markets: [market2]) }

  context "as multi-market manager", :js do
    let!(:user) { create(:user, :market_manager, managed_markets: [market1, market2, empty_market]) }

    before do
      switch_to_subdomain(market1.subdomain)
      sign_in_as(user)
      visit admin_products_path
    end

    context "by market" do
      it "shows all products when unfiltered" do
        expect(page).to have_content(org1_product.name)
        expect(page).to have_content(org2_product.name)
        expect(page).to have_content(org3_product.name)
        expect(page).to have_content(org4_product.name)
      end

      it "shows products for only the selected market" do
        select_option_on_multiselect('#filter-options-market', market1.name)
        click_button "Search"

        expect(page).to have_content(org1_product.name)
        expect(page).to have_content(org2_product.name)

        expect(page).to_not have_content(org3_product.name)
        expect(page).to_not have_content(org4_product.name)

        unselect_option_on_multiselect('#filter-options-market', market1.name)
      end
    end

    context "by organization" do
      it "shows all products when unfiltered" do
        expect(page).to have_content(org1_product.name)
        expect(page).to have_content(org2_product.name)
        expect(page).to have_content(org3_product.name)
        expect(page).to have_content(org4_product.name)
      end

      it "shows products for only the selected supplier" do
        select_option_on_multiselect('#filter-options-supplier', org1.name)
        click_button "Search"

        expect(page).to have_content(org1_product.name)

        expect(page).to_not have_content(org2_product.name)
        expect(page).to_not have_content(org3_product.name)
        expect(page).to_not have_content(org4_product.name)

        unselect_option_on_multiselect('#filter-options-supplier', org1.name)
      end
    end
  end

  context "as single market manager", :js do
    let!(:user) { create(:user, :market_manager, managed_markets: [market1]) }

    before do
      switch_to_subdomain(market1.subdomain)
      sign_in_as(user)

      visit admin_products_path
    end

    context "by market" do
      it "does not show a market filter dropdown" do
        expect(page).to_not have_field("filter_market")
      end
    end

    context "by organization" do
      it "shows all products when unfiltered" do
        expect(page).to have_content(org1_product.name)
        expect(page).to have_content(org2_product.name)
      end

      it "shows products for only the selected organization" do
        select_option_on_multiselect('#filter-options-supplier', org1.name)
        click_button "Search"

        expect(page).to have_content(org1_product.name)
        expect(page).to_not have_content(org2_product.name)

        unselect_option_on_multiselect('#filter-options-supplier', org1.name)
      end
    end
  end

  context "as user in multiple organizations" do
    let!(:user) { create(:user, :market_manager) }

    before do
      user.organizations << org1
      user.organizations << org2

      switch_to_subdomain(market1.subdomain)
      sign_in_as(user)
      visit admin_products_path
    end

    context "by market" do
      it "does not show a market filter dropdown" do
        expect(page).to_not have_field("filter_market")
      end
    end

    context "by organization" do
      it "shows all products when unfiltered" do
        expect(page).to have_content(org1_product.name)
        expect(page).to have_content(org2_product.name)
      end

      it "shows products for only the selected organization" do
        select_option_on_multiselect('#filter-options-supplier', org1.name)
        click_button "Search"

        expect(page).to have_content(org1_product.name)
        expect(page).to_not have_content(org2_product.name)

        unselect_option_on_multiselect('#filter-options-supplier', org1.name)
      end
    end
  end

  context "as user in a single organizations" do
    let!(:user) { create(:user) }

    before do
      user.organizations << org1

      switch_to_subdomain(market1.subdomain)
      sign_in_as(user)
      visit admin_products_path
    end

    context "by market" do
      it "does not show a market filter dropdown" do
        expect(page).to_not have_field("q[delivery_schedules_market_id_in][]")
      end
    end

    context "by organization" do
      it "does not show a organization filter dropdown" do
        expect(page).to_not have_field("q[organization_id_in][]")
      end
    end
  end
end
