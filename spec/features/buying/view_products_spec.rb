require "spec_helper"

feature "Viewing products" do
  let!(:org1) { create(:organization, :seller) }
  let!(:org2) { create(:organization, :seller) }
  let!(:org1_product) { create(:product, organization: org1) }
  let!(:product1_price) { create(:price, product: org1_product) }
  let!(:org2_product) { create(:product, organization: org2) }
  let!(:product2_price) { create(:price, product: org2_product) }
  let(:available_products) { [org1_product, org2_product] }

  let!(:other_org) { create(:organization, :seller) }
  let!(:other_products) { create_list(:product, 3, organization: other_org) }

  let!(:buyer_org) { create(:organization, :buyer) }
  let!(:user) { create(:user, organizations: [buyer_org]) }

  let!(:market) { create(:market, organizations: [org1, org2, buyer_org]) }

  before do
    sign_in_as(user)
  end

  scenario "list of products" do
    click_link "Shop"

    products = Dom::Product.all

    expect(products).to have(2).products
    expect(products.map(&:name)).to match_array(available_products.map(&:name))

    product = available_products.first
    dom_product = Dom::Product.find_by_name(product.name)

    expect(dom_product.organization_name).to have_text(product.organization_name)
    expected_price = "$%.2f" % product.prices.first.sale_price
    expect(dom_product.pricing).to have_text(expected_price)
    expect(dom_product.quantity).to have_text(expected_price)
  end
end
