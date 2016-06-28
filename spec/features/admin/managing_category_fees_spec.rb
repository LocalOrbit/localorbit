require "spec_helper"

describe "Managing Category Fee" do
  let!(:market) { create(:market, :with_category_fee) }
  let!(:user) { create(:user, :market_manager, managed_markets: [market]) }

  before do
    switch_to_subdomain market.subdomain
    sign_in_as user
  end

  it "through the market listing" do
    visit "/admin/markets"

    click_link market.name
    click_link "Fees"
    click_link "Category Fees"
    expect(page).to have_text("Apples")
    expect(page).to have_text(12)
  end

  it "adds an entry" do
    visit "/admin/markets"

    click_link market.name
    click_link "Fees"
    click_link "Category Fees"

    select "All / Fruits", :from => "category_fee[category_id]"

    fill_in "Market Fee %", with: "22"

    click_button "Save"

    expect(page).to have_text("All / Fruits")
    expect(page).to have_text(22)
  end
end
