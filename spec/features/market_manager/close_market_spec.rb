require 'spec_helper'

feature "Market Manager" do
  let!(:market)         { create(:market, :with_addresses, :with_delivery_schedule, closed: true) }
  let!(:seller)         { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:buyer)          { create(:organization, :buyer, :single_location, markets: [market]) }
  let!(:products)       { create_list(:product, 5, :sellable, organization: seller) }
  let!(:market_manager) { create(:user, :market_manager, organizations: [buyer], managed_markets:[market]) }

  scenario "can close a market" do
    switch_to_subdomain market.subdomain
    sign_in_as(market_manager)
    save_and_open_page
  end

  scenario "can open a market"
end

