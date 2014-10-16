module AuthenticationHelpers
  @@data = {}

  def sign_in_as(user, password="password")
    case RSpec.current_example.metadata[:type]
    when :request
      post user_session_path, user: {email: user.email, password: password}
    when :feature
      visit new_user_session_path
      fill_in "Email", with: user.email
      fill_in "Password", with: password
      click_button "Sign In"
    end

    @@data[:user] = user
  end

  def sign_out
    click_link "Sign Out"
  end

  def switch_user(new_user, &_block)
    previous_user = @@data[:user]
    previous_url = current_url

    begin
      sign_out
    rescue Capybara::ElementNotFound
      # we're just not on a page yet
      visit "/"
    end

    sign_in_as(new_user)
    yield
    sign_out
    sign_in_as(previous_user) if previous_user.present?

    visit previous_url
  end

  # Hack to remove a cookie from the cookie jar.
  # Only works on Rack-driven tests.
  def delete_cookie(cookie_name)
    jar = Capybara.current_session.driver.browser.current_session.instance_variable_get(:@rack_mock_session).cookie_jar
    expect(jar[cookie_name]).to be, "Expected cookie jar to contain a cookie named '#{cookie_name}', instead there were: #{jar.to_hash.inspect}\n.Cookie jar looks like: #{jar.inspect}"
    jar.delete(cookie_name)
  end

  
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :feature
  config.include AuthenticationHelpers, type: :request
end
