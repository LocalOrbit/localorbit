require "spec_helper"

feature "Filtering Products List" do
  let!(:org1) { create(:organization, name: "Schrute Farms") }
  let!(:org2) { create(:organization, name: "Funny Farm") }
  let!(:category1) { Category.find_by!(name: "Corn") }
  let!(:category2) { Category.find_by!(name: "Macintosh Apples") }

  let!(:product1) { create(:product, organization: org1, category: category1) }
  let!(:price1)   { create(:price, product: product1) }
  let!(:lot1)     { create(:lot, product: product1) }
  let!(:product2) { create(:product, organization: org1, category: category2) }
  let!(:price2)   { create(:price, product: product2) }
  let!(:lot2)     { create(:lot, product: product2) }

  let!(:product3) { create(:product, organization: org2, category: category1) }
  let!(:price3)   { create(:price, product: product3) }
  let!(:lot3)     { create(:lot, product: product3) }
  let!(:product4) { create(:product, organization: org2, category: category2) }
  let!(:price4)   { create(:price, product: product4) }
  let!(:lot4)     { create(:lot, product: product4) }

  let!(:buyer_org) { create(:organization, :buyer) }
  let!(:user) { create(:user, organizations: [buyer_org]) }

  let!(:market) { create(:market, organizations: [org1, org2, buyer_org]) }

  before do
    sign_in_as(user)
    choose_delivery
  end

  scenario "by seller" do
    visit products_path

    expect(Dom::Product.count).to eq(4)

    Dom::ProductFilter.filter_by_seller(org1)

    expect(Dom::ProductFilter.current_seller).to start_with(org1.name)
    expect(Dom::Product.count).to eq(2)
    expect(Dom::Product.all.map(&:name)).to match_array([product1.name, product2.name])

    Dom::ProductFilter.filter_by_seller(org2)

    expect(Dom::ProductFilter.current_seller).to start_with(org2.name)
    expect(Dom::Product.count).to eq(2)
    expect(Dom::Product.all.map(&:name)).to match_array([product3.name, product4.name])
  end

  scenario "by category" do
    visit products_path

    expect(Dom::Product.count).to eq(4)

    top_level_category = category1.top_level_category
    Dom::ProductFilter.filter_by_category(top_level_category)

    expect(Dom::ProductFilter.current_category).to start_with(top_level_category.name)
    expect(Dom::Product.count).to eq(2)
    expect(Dom::Product.all.map(&:name)).to match_array([product1.name, product3.name])

    top_level_category = category2.top_level_category
    Dom::ProductFilter.filter_by_category(top_level_category)

    expect(Dom::ProductFilter.current_category).to start_with(top_level_category.name)
    expect(Dom::Product.count).to eq(2)
    expect(Dom::Product.all.map(&:name)).to match_array([product2.name, product4.name])
  end

  scenario "by both category and seller" do
    visit products_path

    expect(Dom::Product.count).to eq(4)

    top_level_category = category1.top_level_category
    Dom::ProductFilter.filter_by_category(top_level_category)
    Dom::ProductFilter.filter_by_seller(org1)

    expect(Dom::ProductFilter.current_seller).to start_with(org1.name)
    expect(Dom::ProductFilter.current_category).to start_with(top_level_category.name)
    expect(Dom::Product.count).to eq(1)
    expect(Dom::Product.first.name).to eq(product1.name)

    top_level_category = category2.top_level_category
    Dom::ProductFilter.filter_by_category(top_level_category)
    Dom::ProductFilter.filter_by_seller(org1)

    expect(Dom::ProductFilter.current_seller).to start_with(org1.name)
    expect(Dom::ProductFilter.current_category).to start_with(top_level_category.name)
    expect(Dom::Product.count).to eq(1)
    expect(Dom::Product.first.name).to eq(product2.name)
  end
end
