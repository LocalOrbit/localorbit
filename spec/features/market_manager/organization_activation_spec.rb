require "spec_helper"

feature "Organization activation" do
  given!(:market_manager) { create(:user, managed_markets: [market]) }

  def expect_registraiton_email_link(org)
    expect(current_email.body).to match(Regexp.new(admin_organization_url(org, host: market.domain)))
  end

  def request_account(opts={})
    default_opts = { buying: false, selling: false }
    opts = default_opts.merge!(opts)

    click_link "Request an Account"

    page.find(:checkbox, "registration[buyer]").set(opts[:buying])
    page.find(:checkbox, "registration[seller]").set(opts[:selling])

    fill_in "Organization Name", with: "My Organization"
    fill_in "Contact Name", with: "Jan Smith"
    fill_in "Contact Email", with: "jsmith@example.com"
    fill_in "Password", with: "password"
    fill_in "Retype Password", with: "password"

    fill_in "Address Label", with: "Main St. Location"
    fill_in "Address", with: "1234 Main St."
    fill_in "City", with: "Belding"
    select "Michigan", from: "State"
    fill_in "Postal Code", with: "48809"
    fill_in "Phone", with: "616-717-2929"

    check "registration_terms_of_service"

    click_button "Sign Up"
  end

  def confirm_account(email_address=nil)
    open_last_email_for(email_address)
    visit_in_email "Verify Email Address"
    expect(page).to have_content("Your account was successfully confirmed.")
  end

  background do
    switch_to_subdomain(market.subdomain)
    visit root_path
  end

  context "on a market with auto-activation:" do
    given!(:market) { create(:market, auto_activate_organizations: true) }

    scenario "User requests to buy on the market" do
      email = "jsmith@example.com"

      request_account(email: email, buying: true)
      confirm_account(email)

      fill_in "Email", with: email
      fill_in "Password", with: "password"
      click_button "Sign In"

      expect(page).to have_content("Welcome Jan Smith")
    end

    scenario "User requests to sell on the market" do
      email = "jsmith@example.com"

      request_account(email: email, buying: true, selling: true)
      confirm_account(email)

      fill_in "Email", with: email
      fill_in "Password", with: "password"
      click_button "Sign In"

      expect(page).to have_content("market manager must approve your account before you can shop")

      sign_out

      sign_in_as(market_manager)
      open_last_email_for(market_manager.email)

      expect_registraiton_email_link(Organization.last)

      visit_in_email("Edit Organization")

      expect(page).to have_content("My Organization")
      click_link "Activate"

      expect(page).to have_content("My Organization")
      expect(page).to have_content("Deactivate")
      expect(page).not_to have_content("Activate")
    end
  end

  context "on a market without auto-activation" do
    given!(:market) { create(:market, auto_activate_organizations: false) }

    scenario "User requests to sell on the market" do
      email = "jsmith@example.com"

      request_account(email: email, buying: true, selling: true)
      confirm_account(email)

      fill_in "Email", with: email
      fill_in "Password", with: "password"
      click_button "Sign In"

      expect(page).to have_content("market manager must approve your account before you can shop")

      sign_out

      sign_in_as(market_manager)
      open_last_email_for(market_manager.email)
      expect_registraiton_email_link(Organization.last)

      visit_in_email("Edit Organization")

      expect(page).to have_content("My Organization")
      click_link "Activate"

      expect(page).to have_content("My Organization")
      expect(page).to have_content("Deactivate")
      expect(page).not_to have_content("Activate")
    end

    scenario "User requests to buy on the market" do
      email = "jsmith@example.com"

      request_account(email: email, buying: true, selling: false)
      confirm_account(email)

      fill_in "Email", with: email
      fill_in "Password", with: "password"
      click_button "Sign In"

      expect(page).to have_content("market manager must approve your account before you can shop")

      sign_out

      sign_in_as(market_manager)
      open_last_email_for(market_manager.email)
      expect_registraiton_email_link(Organization.last)

      visit_in_email("Edit Organization")

      expect(page).to have_content("My Organization")
      click_link "Activate"

      expect(page).to have_content("My Organization")
      expect(page).to have_content("Deactivate")
      expect(page).not_to have_content("Activate")
    end
  end
end
