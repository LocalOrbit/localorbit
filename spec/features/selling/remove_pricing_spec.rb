require "spec_helper"

describe "Remove advanced pricing" do
  let(:market)        { create(:market) }
  let!(:organization) { create(:organization, markets: [market]) }
  let!(:user)         { create(:user, organizations: [organization]) }
  let!(:product)      { create(:product, organization: organization) }

  let!(:price) { create(:price, product: product, sale_price: 3) }
  let!(:price2) { create(:price, product: product, sale_price: 2, min_quantity: 100) }

  before do
    sign_in_as(user)
    click_link 'Products'
    click_link product.name
    click_link 'Pricing'
  end

  describe "clicking the delete link on a row" do

    it "removes the price from the product" do
      expect(Dom::PricingRow.count).to eq(2)

      price = Dom::PricingRow.first
      price.click_delete

      expect(Dom::PricingRow.count).to eq(1)
      expect(page).to have_content("Successfully removed price")
    end
  end
end
