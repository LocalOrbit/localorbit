require 'spec_helper'

feature "View Seller Profiles" do
  let!(:buyer)   { create(:organization, :buyer) }
  let!(:seller1) { create(:organization, :seller, who_story: "Funny Farm", how_story: "Via a wagon") }
  let!(:seller2) { create(:organization, :seller) }
  let!(:user)    { create(:user, organizations: [buyer]) }
  let!(:market)  { create(:market, organizations: [buyer, seller1, seller2]) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  scenario "view list of sellers" do
    click_link "Sellers"

    expect(page).to have_content(seller1.name)
    expect(page).to have_content(seller1.name)
    expect(page).not_to have_css('#admin-nav')
  end

  scenario "view a sellers profile" do
    click_link "Sellers"
    click_link seller1.name

    expect(page).to have_content(seller1.who_story)
    expect(page).to have_content(seller1.how_story)
    expect(page).not_to have_css('#admin-nav')
  end

  context "available products" do
    let!(:product1)       { create(:product, :sellable, organization: seller1) }
    let!(:product2)       { create(:product, organization: seller1) }
    let!(:product3)       { create(:product, :sellable, organization: seller2) }

    scenario "view a sellers offerings" do
      visit seller_path(seller1)

      expect(page).to have_content ("Currently Selling")

      products = Dom::Product.all
      expect(products.count).to eq(1)
      expect(products.map(&:name)).to match_array([product1.name])
    end
  end

end
