require "spec_helper"

feature "View a products story" do
  let!(:org1) { create(:organization, name: "Funny Farm", who_story: "Chevy Chase", how_story: "Magic") }
  let!(:location) { create(:location, organization: org1, default_shipping: true) }
  let!(:category1) { create(:category, name: "Vegetables") }
  let!(:category2) { create(:category, name: "Fruits") }

  let!(:product1) { create(:product, organization: org1, category: category1) }
  let!(:product2) { create(:product, organization: org1, category: category2, who_story: "Dan Akroid", how_story: "Science") }

  let!(:buyer_org) { create(:organization, :buyer) }
  let!(:user) { create(:user, organizations: [buyer_org]) }

  let!(:market) { create(:market, organizations: [org1, buyer_org]) }

  before do
    sign_in_as(user)
    visit products_path
  end

  context "fall through to organization stories" do
    scenario "view the 'who' story", js: true do
      product = Dom::Product.first
      product.open_who_story

      expect(page).to have_text(org1.who_story)
    end

    scenario "view the 'how' story", js: true do
      product = Dom::Product.first
      product.open_how_story

      expect(page).to have_text(org1.how_story)
    end
  end

  context "show product stories" do
    scenario "view the 'who' story", js: true do
      product = Dom::Product.all.last
      product.open_who_story

      expect(page).to have_text(product2.who_story)
    end

    scenario "view the 'how' story", js: true do
      product = Dom::Product.all.last
      product.open_how_story

      expect(page).to have_text(product2.how_story)
    end
  end
end
