require "spec_helper"

feature "View a products story", js: true do
  let!(:category1) { Category.find_by!(name: "Corn") }
  let!(:category2) { Category.find_by!(name: "Macintosh Apples") }
  let!(:market) { create(:market, :with_delivery_schedule) }
  let!(:delivery_schedule) { market.delivery_schedules.first }

  let!(:org1)      { create(:organization, :single_location, markets: [market], name: "Funny Farm", who_story: "Chevy Chase", how_story: "Magic") }

  let!(:product1) { create(:product, organization: org1, category: category1, delivery_schedules: [delivery_schedule]) }
  let!(:price1)   { create(:price, product: product1) }
  let!(:lot1)     { create(:lot, product: product1) }

  let!(:product2) { create(:product, organization: org1, category: category2, delivery_schedules: [delivery_schedule], who_story: "Dan Akroid", how_story: "Science", location: org1.locations.first) }
  let!(:price2)   { create(:price, product: product2) }
  let!(:lot2)     { create(:lot, product: product2) }

  let!(:buyer_org) { create(:organization, :single_location, :buyer, markets: [market]) }
  let!(:user)      { create(:user, organizations: [buyer_org]) }

  before do
    switch_to_subdomain market.subdomain
    sign_in_as(user)
    visit products_path
  end

  context "fall through to organization stories" do
    scenario "view the 'who' story" do
      product = Dom::GeneralProduct.find_by_gpname(product1.name)
      product.open_who_story

      expect(page).to have_text(org1.who_story)
    end

    scenario "view the 'how' story" do
      product = Dom::GeneralProduct.find_by_gpname(product1.name)
      product.open_how_story

      expect(page).to have_text(org1.how_story)
    end
  end

  context "show product stories" do
    scenario "view the 'who' story" do
      product = Dom::GeneralProduct.find_by_gpname(product2.name)
      product.open_who_story

      expect(page).to have_text(product2.who_story)
    end

    scenario "view the 'how' story" do
      product = Dom::GeneralProduct.find_by_gpname(product2.name)
      product.open_how_story

      expect(page).to have_text(product2.how_story)
    end
  end
end
