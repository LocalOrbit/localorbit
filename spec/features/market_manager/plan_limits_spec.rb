require "spec_helper"

describe "Plan Limits" do
  let(:plan)      { create(:plan) }
  let!(:market)   { create(:market, plan: plan) }
  let!(:seller)   { create(:organization, :seller, markets: [market]) }
  let!(:product)  { create(:product, :sellable, organization: seller) }

  let!(:user)     { create(:user, managed_markets: [market]) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  context "on the startup plan" do
    let!(:plan) do
      create(:plan,
        discount_codes: false,
        promotions: false,
        custom_branding: false,
        cross_selling: false,
        advanced_pricing: false,
        advanced_inventory: false)
    end

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

    context "from the products list", :js do
      before do
        visit admin_products_path
      end

      it "is not allowed to use advanced pricing" do
        Dom::ProductRow.all.first.click_pricing

        expect(page).to_not have_content("Add New Price")
        expect(page).to_not have_content("Go to Price List")
      end

      it "is not allowed to use advanced inventory" do
        Dom::ProductRow.all.first.click_stock

        expect(page).to_not have_content("Add a lot for")
        expect(page).to_not have_content("Edit Existing lot")
      end
    end

    context "from the product detail page", :js do
      before do
        visit admin_product_path(product)
      end

      it "is not allowed to use advanced pricing" do
        visit admin_product_prices_path(product)

        expect(page).to_not have_css("#add-row")
      end

      it "is not allowed to use advanced inventory" do
        within(".tabs") do
          expect(page).to_not have_content("Inventory")
        end

        expect(page).to_not have_content("Use simple inventory management")
      end
    end

  end
end
