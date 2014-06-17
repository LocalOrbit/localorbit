require 'spec_helper'

feature "Reset password:" do
  let!(:market) { create(:market) }
  let!(:market2) { create(:market) }
  let!(:market3) { create(:market) }
  let!(:organization) { create(:organization, markets:[market]) }
  let!(:organization2) { create(:organization, markets:[market2]) }

  let!(:user) { create(:user, organizations:[organization]) }
  let!(:market_manager) { create(:user, managed_markets: [market]) }

  def send_reset_email(from_subdomain: subdomain)
    switch_to_subdomain(from_subdomain)
    visit new_user_session_path

    click_link "Having trouble signing in?"

    fill_in "Email", with: user.email
    click_button "Send Instructions"
  end

  context "a user resets their password" do
    scenario "on a subdomain of a market they belong to" do
      send_reset_email(from_subdomain: market.subdomain)
      email = open_last_email

      expect(email).to have_subject("Reset password instructions")
      expect(email).to have_body_text(market.name) #Implies market branding
    end

    scenario "on a subdomain of a market they don't belong to defaults marketing to their primary market" do
      send_reset_email(from_subdomain: market2.subdomain)
      email = open_last_email

      expect(email).to have_subject("Reset password instructions")
      expect(email).to have_body_text(market.name) #Implies market branding
    end

    scenario "following email link before 1 week expiration" do
      send_reset_email(from_subdomain: market2.subdomain)

      Timecop.travel(6.days.from_now) do
        open_last_email
        visit_in_email("Change my password")

        fill_in "New password", with: "password1"
        fill_in "Confirm new password", with: "password1"
        click_button "Change Password"

        expect(page).to have_content("Welcome #{user.email}")
      end
    end

    scenario "following email link after 1 week expiration" do
      send_reset_email(from_subdomain: market2.subdomain)

      Timecop.travel(8.days.from_now) do
        open_last_email
        visit_in_email("Change my password")

        fill_in "New password", with: "password1"
        fill_in "Confirm new password", with: "password1"
        click_button "Change Password"

        expect(page).to have_content("Reset password token has expired")
      end
    end
  end
end
