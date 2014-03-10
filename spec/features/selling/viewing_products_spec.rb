require "spec_helper"

describe "Viewing products" do
  let!(:market_manager) { create(:user, :market_manager)}
  let!(:market) { market_manager.managed_markets.first }
  let!(:market2) { create(:market, managers: [market_manager])}
  let!(:org1) { create(:organization, markets: [market]) }
  let!(:org2) { create(:organization, markets: [market]) }
  let!(:product) { create(:product, organization: org1) }
  let!(:lot1)  { create(:lot, product: product) }
  let!(:lot2)  { create(:lot, product: product) }

  context "seller" do
    let!(:user) { create(:user, organizations: [org1]) }

    before do
      sign_in_as(user)
    end

    it "shows a list of products which the owner manages" do
      click_link "Products"

      product = Dom::ProductRow.first
      expect(product.name).to have_content(product.name)
      expect(product.stock).to have_content(lot1.quantity + lot2.quantity)
      expect(product.seller).to be_blank
      expect(product.market).to be_blank
    end

    it "shows a paginated list of products" do
      create_list(:product, 2, organization: org1)

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
      click_link "Products"

      product = Dom::ProductRow.first
      expect(product.name).to have_content(product.name)
      expect(product.seller).to have_content(org1.name)
      expect(product.market).to have_content(org1.markets.first.name)
      expect(product.stock).to have_content(lot1.quantity + lot2.quantity)
    end
  end
end
