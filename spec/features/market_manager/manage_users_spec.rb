require 'spec_helper'

describe "Market Manager" do
  let(:market_manager) { create(:user, :market_manager) }
  let(:market) { market_manager.managed_markets.first }
  let!(:org) { create(:organization, markets: [market]) }
  let!(:user) { create(:user, organizations: [org]) }

  it "removes a user from an organization", :js do
    switch_to_subdomain(market.subdomain)
    sign_in_as(market_manager)

    click_link "Market Admin"
    click_link "Organizations"

    click_link org.name
    click_link "Users"

    user_row = Dom::Admin::UserRow.find_by_email(user.email)
    user_row.remove!

    expect(page).to have_content("Successfully removed #{user.email}.")
    expect(Dom::Admin::UserRow.find_by_email(user.email)).to be_nil
  end
end

