require 'spec_helper'

feature 'User resets password' do
  scenario 'user enters a valid email' do
    user = create :user

    visit new_user_password_path

    fill_in 'Email', with: user.email
    click_button 'Send Instructions'

    expect(page).to have_text 'You will receive an email with instructions'
    expect(page).to have_current_path new_user_session_path
  end

  scenario 'user enters an invalid email' do
    visit new_user_password_path

    fill_in 'Email', with: 'username@example.com'
    click_button 'Send Instructions'

    expect(page).to have_text 'Email not found'
  end

  scenario 'user changes password' do
    token = create(:user).send_reset_password_instructions

    visit edit_user_password_path(reset_password_token: token)

    fill_in 'New password', with: 'p4ssw0rd'
    fill_in 'Confirm new password', with: 'p4ssw0rd'
    click_button 'Change Password'

    expect(page).to have_text 'Your password was changed successfully.'
    expect(page).to have_current_path dashboard_path
  end

  scenario 'password reset token is invalid' do
    visit edit_user_password_path(reset_password_token: 'token')

    fill_in 'New password', with: 'p4ssw0rd'
    fill_in 'Confirm new password', with: 'p4ssw0rd'
    click_button 'Change Password'

    expect(page).to have_text 'Reset password token is invalid'
  end
end