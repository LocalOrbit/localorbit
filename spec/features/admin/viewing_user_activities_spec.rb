require "spec_helper"

feature "User Activities (User Event Log)", audit: true do
  let!(:market) { create(:market, name: "Foo Market", po_payment_term: 30, timezone: "Eastern Time (US & Canada)") }
  let!(:buyer)  { create(:organization, name: "Foo Buyer", markets: [market], can_sell: false) }
  let(:user)    { create(:user, :admin) }

  scenario "An admin can view user activities" do
    market.update!(name: "Bar Market", audit_comment: "This is a comment.")

    sign_in_as(user)
    visit "/admin/activities?per_page=100"
    expect(page).to have_content("User Event Log")
    expect(page).to have_content("Market update")
    expect(page).to have_content("Foo Market")
    expect(page).to have_content("Bar Market")
    expect(page).to have_content("This is a comment.")
  end

end
