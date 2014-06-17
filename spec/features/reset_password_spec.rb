require 'spec_helper'

feature "Reset password:" do
  let!(:market) { create(:market) }
  let!(:market2) { create(:market) }
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
  end
end
