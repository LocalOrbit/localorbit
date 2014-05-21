require 'spec_helper'

feature "Buyer Financial Overview" do
  let!(:market)  { create(:market, po_payment_term: 30, timezone: "Eastern Time (US & Canada)") }
  let!(:seller)  { create(:organization, markets: [market]) }
  let!(:seller2) { create(:organization, markets: [market]) }
  let!(:buyer) { create(:organization, :single_location, markets: [market], can_sell: false) }

  let!(:user)    { create(:user, organizations: [buyer]) }

  let!(:kale) { create(:product, :sellable, organization: seller, name: "Kale") }
  let!(:peas) { create(:product, :sellable, organization: seller, name: "Peas") }
  let!(:from_different_seller) { create(:product, :sellable, organization: seller2, name: "Apples") }

  scenario "Buyer's default financial view is the overview" do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
    click_link "Dashboard"
    click_link "Financials"

    expect(page).to have_content("Payments Due")
    expect(page).to have_content("This is a snapshot")
  end
end
