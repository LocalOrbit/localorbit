require "spec_helper"

feature "Filtering Products List" do
  let!(:org1) { create(:organization, name: "Schrute Farms") }
  let!(:org2) { create(:organization, name: "Funny Farm") }
  let!(:category1) { create(:category, name: "Vegetables") }
  let!(:category2) { create(:category, name: "Fruits") }
  let!(:product1) { create(:product, organization: org1, category: category1) }
  let!(:product2) { create(:product, organization: org2, category: category2) }

  let!(:buyer_org) { create(:organization, :buyer) }
  let!(:user) { create(:user, organizations: [buyer_org]) }

  let!(:market) { create(:market, organizations: [org1, org2, buyer_org]) }

  before do
    sign_in_as(user)
  end

  scenario "by seller" do
    visit products_path

    expect(Dom::Product.count).to eq(2)

    Dom::ProductFilter.filter_by_seller(org1)

    expect(Dom::ProductFilter.current_seller).to eq(org1.name)
    expect(Dom::Product.count).to eq(1)
    expect(Dom::Product.first.name).to eq(product1.name)

    Dom::ProductFilter.filter_by_seller(org2)

    expect(Dom::ProductFilter.current_seller).to eq(org2.name)
    expect(Dom::Product.count).to eq(1)
    expect(Dom::Product.first.name).to eq(product2.name)
  end

  scenario "by category" do
    visit products_path

    expect(Dom::Product.count).to eq(2)

    Dom::ProductFilter.filter_by_category(category1)

    expect(Dom::ProductFilter.current_category).to eq(category1.name)
    expect(Dom::Product.count).to eq(1)
    expect(Dom::Product.first.name).to eq(product1.name)

    Dom::ProductFilter.filter_by_category(category2)

    expect(Dom::ProductFilter.current_category).to eq(category2.name)
    expect(Dom::Product.count).to eq(1)
    expect(Dom::Product.first.name).to eq(product2.name)

  end
end
