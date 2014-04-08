module AuthenticationHelpers
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
  end

  def sign_out
    click_link "Sign Out"
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :feature
  config.include AuthenticationHelpers, type: :request
end
