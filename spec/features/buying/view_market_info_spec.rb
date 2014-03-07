require "spec_helper"

feature "Viewing Market Info" do
  let!(:buyer) { create(:organization, :buyer) }
  let!(:seller1) { create(:organization, :seller) }
  let!(:seller2) { create(:organization, :seller) }
  let!(:user) { create(:user, organizations: [buyer]) }

  let!(:market) { create(:market, organizations: [buyer, seller1, seller2]) }
  let!(:address) { create(:market_address, market: market) }
  let!(:tuesday_deliveries) { create(:delivery_schedule, market: market) }
  let!(:thursday_deliveries) { create(:delivery_schedule, market: market, day: 4) }

  before do
    sign_in_as(user)
  end

  scenario "current market information is visible" do
    click_link "Market Info"

    expect(page).to have_content(market.name)
    expect(page).to have_content(market.contact_name)
    expect(page).to have_content(market.contact_email)
    expect(page).to have_content(market.policies)
    expect(page).to have_content(market.profile)

    sellers = Dom::MarketSellers.all
    expect(sellers.map(&:name)).to match_array([seller1.name, seller2.name])

    expect(page).to have_content(tuesday_deliveries.weekday)
    expect(page).to have_content(thursday_deliveries.weekday)
  end
end
