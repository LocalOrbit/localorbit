require "spec_helper"

feature "User can use an auth_token" do
  let!(:user) { create(:user, :admin) }

  scenario "can see a single page" do
    visit dashboard_path(auth_token: user.auth_token)

    within ".l-app-header" do
      expect(page).to have_content("Sign Out")
      expect(page).to have_content(user.email)
    end
  end

  scenario "does not carry to the next request" do
    visit dashboard_path(auth_token: user.auth_token)

    click_link "Markets", match: :first

    expect(page).to have_content("Please Sign In")
  end

  scenario "does not authorize invalid tokens" do
    visit dashboard_path(auth_token: "let-me-in")

    expect(page).to have_content("Please Sign In")
  end

  scenario "does not authorize expired tokens" do
    visit dashboard_path(auth_token: user.auth_token(-10.minutes))

    expect(page).to have_content("Please Sign In")
  end
end
