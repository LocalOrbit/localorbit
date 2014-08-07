require "spec_helper"

feature "User Activities (User Event Log)" do
  let!(:market) { create(:market, name: "Foo Market", po_payment_term: 30, timezone: "Eastern Time (US & Canada)") }
  let!(:buyer)  { create(:organization, name: "Foo Buyer", markets: [market], can_sell: false) }
  let(:user)    { create(:user, :admin) }

  scenario "An admin can view user activities" do
    Market.enable_auditing # auditing is turned off for test speed
    market.update!(name: "Bar Market", audit_comment: "This is a comment.")
    Market.disable_auditing # turn it back off

    sign_in_as(user)
    visit "/admin/activities"
    expect(page).to have_content("User Event Log")
    expect(page).to have_content("Market update")
    expect(page).to have_content("Foo Market")
    expect(page).to have_content("Bar Market")
    expect(page).to have_content("This is a comment.")
  end

end
