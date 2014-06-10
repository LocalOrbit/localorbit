require "spec_helper"

describe "Viewing products" do
  let!(:market_manager) { create(:user, :market_manager)}
  let!(:market) { market_manager.managed_markets.first }
  let!(:market2) { create(:market, managers: [market_manager])}
  let!(:org1) { create(:organization, markets: [market]) }
  let!(:org2) { create(:organization, markets: [market]) }

  let!(:apples)       { create(:product, organization: org1, name: "Apples") }
  let!(:apples_price) { create(:price, product: apples, sale_price: 10.00, min_quantity: 1) }
  let!(:apples_lot)   { create(:lot, product: apples, quantity: 10) }

  let!(:bananas)       { create(:product, organization: org1, name: "Bananas") }
  let!(:bananas_price) { create(:price, product: bananas, sale_price: 1.00, min_quantity: 1) }
  let!(:bananas_lot)   { create(:lot, product: bananas, quantity: 100) }

  let!(:grapes)       { create(:product, organization: org1, name: "Grapes") }
  let!(:grapes_price) { create(:price, product: grapes, sale_price: 5.00, min_quantity: 1) }
  let!(:grapes_lot)   { create(:lot, product: grapes, quantity: 1) }


  before do
    switch_to_subdomain(market.subdomain)
  end

  context "seller" do
    let!(:user) { create(:user, organizations: [org1]) }

    before do
      sign_in_as(user)
    end

    it "shows a list of products which the owner manages" do
      within '#admin-nav' do
        click_link 'Products'
      end

      product = Dom::ProductRow.first
      expect(product.name).to have_content(apples.name)
      expect(product.stock).to have_content(apples.lots.map(&:quantity).join(" "))
      expect(product.seller).to be_blank
      expect(product.market).to be_blank
    end

    it "shows a paginated list of products" do
      visit admin_products_path(per_page: 2)

      expect(Dom::ProductRow.count).to eq(2)

      click_link "Next"

      expect(Dom::ProductRow.count).to eq(1)
    end
  end

  context "market manager" do
    before do
      sign_in_as(market_manager)
    end

    it "shows a list of products which the owner manages" do
      within '#admin-nav' do
        click_link 'Products'
      end

      product = Dom::ProductRow.first
      expect(product.name).to have_content(apples.name)
      expect(product.seller).to have_content(org1.name)
      expect(product.market).to have_content(org1.markets.first.name)
      expect(product.stock).to have_content(apples.lots.map(&:quantity).join(" "))
    end
  end

  context "sorting", :js do
    before do
      sign_in_as(market_manager)
      visit admin_products_path
    end

    context "by name" do
      it "ascending" do
        click_header("name")

        first = Dom::ProductRow.first
        expect(first.name).to have_content(apples.name)
      end

      it "descending" do
        click_header_twice("name")

        first = Dom::ProductRow.first
        expect(first.name).to have_content(grapes.name)
      end
    end

    context "by price" do
      it "ascending" do
        click_header("price")

        first = Dom::ProductRow.first
        expect(first.name).to have_content(bananas.name)
      end

      it "descending" do
        click_header_twice("price")

        first = Dom::ProductRow.first
        expect(first.name).to have_content(apples.name)
      end
    end

    context "by stock" do
      it "ascending" do
        click_header("stock")

        first = Dom::ProductRow.first
        expect(first.name).to have_content(grapes.name)
      end

      it "descending" do
        click_header_twice("stock")

        first = Dom::ProductRow.first
        expect(first.name).to have_content(bananas.name)
      end
    end
  end

  context "updating prices and quantities", js: true do
    let!(:user) { create(:user, organizations: [org1]) }

    it "maintains filters when updating updating price or inventory" do
      sign_in_as(market_manager)

      visit admin_products_path

      select market.name, from: "product-filter-market"
      # Don't know what else to do here, and I've been working on this for too long
      sleep 2

      product = Dom::ProductRow.find_by_name("Grapes")
      product.click_stock

      fill_in "Quantity", with: 99
      click_button "Save Inventory"

      expect(page.find("#product-filter-market").find("option[selected=selected]").text).to eq(market.name)
    end

    it "updates simple inventory" do
      sign_in_as(user)
      visit admin_products_path

      product = Dom::ProductRow.find_by_name("Grapes")
      product.click_stock

      fill_in "Quantity", with: 99
      click_button "Save Inventory"

      product = Dom::ProductRow.find_by_name("Grapes")
      
      expect(product.stock).to have_content("99")
    end

    it "updates advanced inventory" do
      grapes.update_attributes!(use_simple_inventory: false)

      sign_in_as(user)
      visit admin_products_path

      product = Dom::ProductRow.find_by_name("Grapes")
      product.click_stock

      fill_in "lot_number", with: 32
      fill_in "Quantity", with: 45
      fill_in "Good From", with: "1 May 2054"
      fill_in "Expires On", with: "30 May 2054"

      click_button "Save Lot"

      product = Dom::ProductRow.find_by_name("Grapes")

      expect(product.stock).to have_content("46")
    end

    it "updates advanced pricing" do
      sign_in_as(user)
      visit admin_products_path

      product = Dom::ProductRow.find_by_name("Grapes")
      product.click_pricing

      fill_in "Sale Price", with: 12
      fill_in "Min Qty", with: 5

      click_button "Save Price"

      product = Dom::ProductRow.find_by_name("Grapes")

      expect(product.pricing).to have_content("$12.00 5+ boxes")

      product.click_pricing
      net_price  = find_field("Net Price")
      sale_price = find_field("Sale Price")
      expect(net_price.value).to eq("11.28")
      expect(sale_price.value).to eq("12.00")
    end
  end
end
