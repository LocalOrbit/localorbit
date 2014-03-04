require "spec_helper"

feature "User signing in" do
  let!(:user) { create(:user, :admin) }

  scenario "A user can sign in" do
    visit "/"

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"

    expect(page).to have_text("Dashboard")
  end

  scenario "A returning users login is remembered" do
    visit "/"
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    check "Remember me"
    click_button "Sign in"

    # Hack to remove a cookie from the cookie jar
    jar = Capybara.current_session.driver.browser.current_session.instance_variable_get(:@rack_mock_session).cookie_jar
    jar.delete('_local_orbit_session')

    visit new_user_session_path
    expect(page).to have_text("Dashboard")
    expect(page).to have_text("You are already signed in.")
  end

  # Make sure the cookie jar hack still works
  scenario "A returning users session is remembered" do
    visit "/"
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"

    # Hack to remove a cookie from the cookie jar
    jar = Capybara.current_session.driver.browser.current_session.instance_variable_get(:@rack_mock_session).cookie_jar
    jar.delete('_local_orbit_session')

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
end
