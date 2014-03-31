require "spec_helper"

feature "User signing in" do
  let!(:user) { create(:user, :admin) }
  let(:cookie_name) { "_local_orbit_session_test" }

  scenario "A user can sign in" do
    visit "/"

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page).to have_text("Dashboard")
  end

  scenario "A returning users login is remembered" do
    visit "/"
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    check "Keep me signed in."
    click_button "Sign In"

    # Hack to remove a cookie from the cookie jar
    jar = Capybara.current_session.driver.browser.current_session.instance_variable_get(:@rack_mock_session).cookie_jar
    jar.delete(cookie_name)

    visit new_user_session_path
    expect(page).to have_text("Dashboard")
    expect(page).to have_text("You are already signed in.")
  end

  # Make sure the cookie jar hack still works
  scenario "A returning users session is remembered" do
    visit "/"
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    # Hack to remove a cookie from the cookie jar
    jar = Capybara.current_session.driver.browser.current_session.instance_variable_get(:@rack_mock_session).cookie_jar
    jar.delete(cookie_name)

    visit "/"
    expect(page).to_not have_text("Dashboard")
  end

  scenario "A user can sign out" do
    sign_in_as user
    visit "/"
    click_link "Sign Out"
    expect(page).not_to have_text("Dashboard")
    expect(page).to have_text("You need to sign in or sign up before continuing.")
  end

  scenario "After logging in an admin should be on the dashboard" do
    visit "/"

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page.current_path).to eq(dashboard_path)
  end

  scenario "After logging in a market manager should be on the dashboard" do
    user = create(:user, :market_manager)
    visit "/"

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page.current_path).to eq(dashboard_path)
  end

  scenario "After logging in a seller should be on the dashboard" do
    org = create(:organization, :seller)
    user = create(:user, organizations: [org])
    visit "/"

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page.current_path).to eq(dashboard_path)
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
end
