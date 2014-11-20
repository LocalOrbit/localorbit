require "spec_helper"

describe "Plan Limits" do
  let(:plan)      { create(:plan) }
  let!(:market)   { create(:market, :with_delivery_schedule, :with_address, plan: plan) }
  let!(:seller)   { create(:organization, :seller, markets: [market]) }
  let!(:buyer)    { create(:organization, :buyer, markets: [market]) }
  let!(:product)  { create(:product, :sellable, organization: seller) }
  let!(:order_item) {create(:order_item, order: order, product: product)}
  let(:order)     { create :order, :with_items, organization: buyer, market: market }

  let(:user)      { create(:user, managed_markets: [market]) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  context "as an admin" do
    let!(:user) { create(:user, :admin)}
    it "is allowed to view table tents or posters" do
      visit order_path(order)
      # expect(page).to_not have_text "404"
      expect(page).to have_text "Download the table tents"
      expect(page).to have_selector ".app-download-table-tents-btn"
    end
  end

  context "as a seller" do
    let!(:user) {create(:user, organizations:[seller] )}

    it "is not allowed to view table tents or posters" do
      visit admin_order_path(order)
      # expect(page).to_not have_text "404"
      expect(page).to_not have_text "Download the table tents"
      expect(page).to_not have_selector ".app-download-table-tents-btn"
    end
  end

  context "as a buyer" do
    let!(:user) { create(:user, managed_markets: [], organizations: [buyer])}

    context "on a grow plan" do
      let!(:plan) { create(:plan, :grow) }

      it "is allowed to view table tents or posters" do
        visit order_path(order)
        # expect(page).to_not have_text "404"
        expect(page).to have_text "Download the table tents"
        expect(page).to have_selector ".app-download-table-tents-btn"
      end
    end
  end

  context "as a market manager" do
    context "on a grow plan" do
      let!(:plan) { create(:plan, :grow) }

      it "is allowed to view table tents or posters" do
        user.organizations << buyer
        visit order_path(order)
        # expect(page).to_not have_text "404"
        expect(page).to have_text "Download the table tents"
        expect(page).to have_selector ".app-download-table-tents-btn"
      end
    end

    context "on the startup plan" do
      let!(:plan) { create(:plan, :start_up) }

      it "is not allowed to manage discount codes" do
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

      it "is not allowed to view table tents or posters" do
        user.organizations << buyer
        visit order_path(order)
        # expect(page).to_not have_text "404"
        expect(page).to_not have_text "Download the table tents"
        expect(page).to_not have_selector ".app-download-table-tents-btn"
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

        it "is not allowed to use advanced inventory" do
          within(".tabs") do
            expect(page).to_not have_content("Inventory")
          end

          expect(page).to_not have_content("Use simple inventory management")
        end
      end

      context "from product price page with existing prices", :js do
        before do
          visit admin_product_prices_path(product)
        end

        it "is not allowed to add new advanced prices" do
          expect(page).to_not have_link("Add Price")
        end
      end

      context "from product price page without existing prices", :js do
        before do
          Price.delete_all
          visit admin_product_prices_path(product.reload)
        end

        it "is not allowed to change the affected market" do
          expect(page).to_not have_css("#price_market_id")
        end

        it "is not allowed to change the affected buyer" do
          expect(page).to_not have_css("#price_organization_id")
        end

        it "is not allowed to change the minimum quantity" do
          expect(page).to_not have_css("#price_min_quantity")
        end
      end
    end
  end
end
