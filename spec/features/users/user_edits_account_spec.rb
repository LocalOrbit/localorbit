require "spec_helper"

feature "User edits her account" do
  let(:market)       { create(:market) }
  let(:organization) { create(:organization, markets: [market]) }
  let(:user)         { create(:user, :buyer, password: "password", organizations: [organization]) }

  scenario "user changes her account details" do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)

    click_link "Account"
    click_link "E-mail & Password"

    fill_in "Name", with: "Amy Body"
    fill_in "Email", with: "amy@example.com"
    fill_in "Password", match: :first, with: "abcd1234"
    fill_in "Confirm Password", with: "abcd1234"
    fill_in "Current password", with: "password"
    click_button "Save Changes"

    expect(page).to have_content("You updated your account successfully")
    user.reload
    expect(user.name).to eq("Amy Body")
    expect(user.email).to eq("amy@example.com")
  end
end
