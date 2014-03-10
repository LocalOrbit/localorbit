require 'spec_helper'

feature "View Seller Profiles" do
  let!(:buyer)   { create(:organization, :buyer) }
  let!(:seller1) { create(:organization, :seller, who_story: "Funny Farm", how_story: "Via a wagon") }
  let!(:seller2) { create(:organization, :seller) }
  let!(:user)    { create(:user, organizations: [buyer]) }
  let!(:market)  { create(:market, organizations: [buyer, seller1, seller2]) }


  before do
    sign_in_as(user)
  end

  scenario "view list of sellers" do
    click_link "Sellers"

    expect(page).to have_content(seller1.name)
    expect(page).to have_content(seller1.name)
  end

  scenario "view a sellers profile" do
    click_link "Sellers"
    click_link seller1.name

    expect(page).to have_content(seller1.who_story)
    expect(page).to have_content(seller1.how_story)
  end

end
