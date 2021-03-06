require "spec_helper"

describe "Remove advanced pricing" do
  let!(:organization) { create(:organization, :seller) }
  let!(:market)       { create(:market, :with_delivery_schedule, organizations: [organization]) }
  let!(:user)         { create(:user, :supplier, organizations: [organization]) }
  let!(:product)      { create(:product, organization: organization) }

  let!(:price) { create(:price, product: product, sale_price: 3) }
  let!(:price2) { create(:price, product: product, sale_price: 2, min_quantity: 100) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
    within "#admin-nav" do

      click_link "Products"
    end
    click_link product.name
    click_link "Pricing"
  end

  describe "clicking the delete link on a row" do
    it "removes the price from the product" do
      expect(Dom::PricingRow.count).to eq(3)

      price = Dom::PricingRow.first
      price.click_delete

      expect(page).to have_content("Successfully removed price")
      expect(Dom::PricingRow.all_classes).to eq(["price", "add-price add-row price is-hidden"])
    end
  end
end
