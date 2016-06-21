require "spec_helper"

describe "Managing Category Fee" do
  let!(:market) { create(:market, :with_category_fee) }
  let!(:user) { create(:user, :market_manager, managed_markets: [market]) }

  before do
    switch_to_subdomain market.subdomain
    save_and_open_page
    sign_in_as user
  end

  it "through the market listing" do
    visit "/admin/markets"

    click_link market.name
    save_and_open_page
    click_link "Fees"
    expect(page).to have_text(category.name)
    expect(page).to have_text(category.fee_pct)
  end
end
