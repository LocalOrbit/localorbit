require "spec_helper"

describe "Viewing featured promotion" do
  let!(:market)    { create(:market, :with_delivery_schedule, :with_address) }
  let!(:seller)    { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:product)   { create(:product, :sellable, organization: seller) }
  let!(:promotion) { create(:promotion, :active, product: product, market: market, body: "Big savings!") }

  let!(:buyer) { create(:organization, :buyer, :single_location, markets: [market]) }
  let!(:user) { create(:user, organizations: [buyer]) }

  context "with inventory" do
    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as user
    end

    context "with a price" do
      before do
        visit products_path
      end

      it "shows the featured product" do
        expect(page).to have_content("Featured")
      end

      it "can be toggled between minimized and maximized", js: true do
        expect(page).to have_content("Big savings!")
        find(".featured-product-toggle").trigger("click")

        expect(page).not_to have_content("Big savings!")

        find(".featured-product-toggle").trigger("click")
        expect(page).to have_content("Big savings!")
      end
    end

    context "without a price" do
      before do
        product.prices.delete_all
        visit products_path
      end

      it "does not show the featured product" do
        expect(page).to_not have_content("Featured")
      end
    end

    context "without a price for the market" do
      before do
        product.prices.first.update(market_id: market.id + 1)
        visit products_path
      end

      it "does not show the featured product" do
        expect(page).to_not have_content("Featured")
      end
    end

    context "without a price for the buyer" do
      before do
        product.prices.first.update(organization_id: buyer.id + 1)
        visit products_path
      end

      it "does not show the featured product" do
        expect(page).to_not have_content("Featured")
      end
    end
  end

  context "with expired inventory" do
    before do
      Timecop.travel(5.days.ago) do
        product.lots.first.update(created_at: 3.days.ago)
        product.lots.first.update(number: "1", expires_at: 2.days.ago)
      end

      switch_to_subdomain(market.subdomain)
      sign_in_as user

      visit products_path
    end

    it "does not show the featured product" do
      expect(page).to_not have_content("Featured")
    end

  end

  context "without inventory" do
    before do
      product.lots.first.update(quantity: 0)

      switch_to_subdomain(market.subdomain)
      sign_in_as user

      visit products_path
    end

    it "does not show the featured product" do
      expect(page).to_not have_content("Featured")
    end
  end
end
