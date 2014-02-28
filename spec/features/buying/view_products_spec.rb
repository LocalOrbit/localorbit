require "spec_helper"

feature "Viewing products" do
  let!(:org1) { create(:organization, :seller) }
  let!(:org2) { create(:organization, :seller) }
  let!(:org1_products) { create_list(:product, 3, organization: org1) }
  let!(:org2_products) { create_list(:product, 3, organization: org2) }
  let(:available_products) { org1_products + org2_products }

  let!(:other_org) { create(:organization, :seller) }
  let!(:other_products) { create_list(:product, 3, organization: other_org) }

  let!(:buyer_org) { create(:organization, :buyer) }
  let!(:user) { create(:user, organizations: [buyer_org]) }

  let!(:market) { create(:market, organizations: [org1, org2, buyer_org]) }

  before do
    sign_in_as(user)
  end

  scenario "list of products" do
    visit products_path

    products = Dom::Product.all

    expect(products).to have(6).products
    expect(products.map(&:name)).to match_array(available_products.map(&:name))

    product = available_products.first
    dom_product = Dom::Product.find_by_name(product.name)

    expect(dom_product.organization_name).to have_text(product.organization_name)
  end
end
