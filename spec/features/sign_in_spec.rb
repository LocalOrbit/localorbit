require "spec_helper"

feature "User signing in" do
  let!(:first_market) { create(:market) }
  let!(:admin) { create(:user, :admin) }
  let(:cookie_name) { "_local_orbit_session_test" }

  scenario "A user can sign in" do
    visit "/"

    fill_in "Email", with: admin.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page).to have_text("Dashboard")
  end

  scenario "A returning users login is remembered" do
    visit "/"
    fill_in "Email", with: admin.email
    fill_in "Password", with: "password"
    check "Keep me signed in."
    click_button "Sign In"

    # Hack to remove a cookie from the cookie jar
    jar = Capybara.current_session.driver.browser.current_session.instance_variable_get(:@rack_mock_session).cookie_jar
    jar.delete(cookie_name)

    visit new_user_session_path
    expect(page).to have_text("Dashboard")
  end

  # Make sure the cookie jar hack still works
  scenario "A returning users session is remembered" do
    visit "/"
    fill_in "Email", with: admin.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    # Hack to remove a cookie from the cookie jar
    jar = Capybara.current_session.driver.browser.current_session.instance_variable_get(:@rack_mock_session).cookie_jar
    jar.delete(cookie_name)

    visit "/"
    expect(page).to_not have_text("Dashboard")
  end

  scenario "A user can sign out" do
    sign_in_as admin
    visit "/"
    click_link "Sign Out"
    expect(page).not_to have_text("Dashboard")
    expect(page).to have_text("Signed out successfully")
    expect(page).to have_text("Please Sign In")
  end

  scenario "After logging in an admin should be on the dashboard" do
    visit "/"

    fill_in "Email", with: admin.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page.current_path).to eq(dashboard_path)
  end

  scenario "After logging in through the organizations page an admin should be on the organizations page" do
    visit admin_organizations_path

    fill_in "Email", with: admin.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page.current_path).to eq(admin_organizations_path)
  end

  scenario "After logging in a market manager should be on the dashboard" do
    user = create(:user, :market_manager)
    visit "/"

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page.current_path).to eq(dashboard_path)
  end

  scenario "After logging in through the organizations page a market manager should be on the organizations page" do
    user = create(:user, :market_manager)
    switch_to_subdomain(user.managed_markets.first.domain)

    visit admin_organizations_path

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page.current_path).to eq(admin_organizations_path)
  end

  scenario "After logging in a seller should be on the dashboard" do
    market = create(:market)
    org = create(:organization, :seller, :single_location, markets: [market])
    user = create(:user, organizations: [org])

    visit "/"

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page.current_path).to eq(dashboard_path)
  end

  scenario "After logging in through the products page a seller should be on the products page" do
    market = create(:market)
    org = create(:organization, :seller, markets: [market])
    user = create(:user, organizations: [org])

    switch_to_subdomain(market.subdomain)

    visit admin_products_path

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page.current_path).to eq(admin_products_path)
  end

  scenario "After logging in at the naked domain a buyer should be on the shop page" do
    market = create(:market)
    create(:delivery_schedule, market: market)
    org = create(:organization, :buyer, :single_location, markets: [market])
    user = create(:user, organizations: [org])

    visit "/"

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page.current_path).to eq(products_path)
  end

  scenario "After logging in a buyer should be on the shop page" do
    market = create(:market)
    create(:delivery_schedule, market: market)
    org = create(:organization, :buyer, :single_location, markets: [market])
    user = create(:user, organizations: [org])

    switch_to_subdomain market.subdomain

    visit "/"

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page.current_path).to eq(products_path)
  end

  context "As a suspended user", :suspend_user do
    let!(:market) { create(:market) }
    let!(:org2) { create(:organization, markets: [market]) }
    let!(:selling_user) { create(:user, organizations: [org2]) }

    before do
      suspend_user(user: selling_user, org: org2)
    end

    scenario "logging in as a suspended user" do
      switch_to_subdomain(market.subdomain)
      sign_in_as(selling_user)

      expect(page).to have_content("Your account has been suspended.")
    end
  end

  context "As a market manager logging into a market that they do not manage" do
    let!(:market_manager) { create(:user, managed_markets: [market1]) }
    let!(:market1) { create(:market) }
    let!(:market2) { create(:market) }

    scenario "sees 404" do
      switch_to_subdomain(market2.subdomain)
      sign_in_as(market_manager)

      expect(page).not_to have_content("suspended")
      expect(page).to have_content("The page you were looking for doesn't exist (404)")
    end
  end
end
