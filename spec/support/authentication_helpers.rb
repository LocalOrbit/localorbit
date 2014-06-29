module AuthenticationHelpers
  @@data = {}

  def sign_in_as(user, password = 'password')
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

  def switch_user(new_user, &block)
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
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :feature
  config.include AuthenticationHelpers, type: :request
end
