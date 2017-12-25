require "spec_helper"

feature "Accepting an invitation to an organization" do

  let(:org) { create(:organization) }
  # let(:inviter) { create(:user, :market_manager) }
  # let(:market) { inviter.managed_markets.first }
  let(:user) { create(:user, organizations: [org]) }

  before do
    user.invite!
  end

  scenario "a user signs up and sets their name & password" do
    visit accept_user_invitation_path(invitation_token: user.raw_invitation_token)
    fill_in "Name", with: "Sam Body"
    fill_in "Email", with: "sam@example.com"
    fill_in "Password", with: "abcd1234"
    fill_in "Password confirmation", with: "abcd1234"
    click_button "Save"

    expect(page).to have_content("Welcome Sam Body")
    user.reload
    expect(user.name).to eq("Sam Body")
    expect(user.email).to eq("sam@example.com")
  end

end
