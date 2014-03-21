require "spec_helper"

describe "Admin Managing Market Managers" do
  let(:market) { create(:market) }

  before do
    switch_to_subdomain(market.subdomain)
  end

  describe 'as a normal user' do
    let!(:normal_user) { create(:user, role: 'user') }
    let!(:org) { create(:organization, markets: [market], users: [normal_user])}

    it 'I can not manage market managers' do
      sign_in_as normal_user

      visit admin_market_managers_path(market)

      expect(page).to have_text("page you were looking for doesn't exist")
    end
  end

  describe 'as a market manager' do
    let(:user) { create(:user, managed_markets: [market]) }

    before do
      sign_in_as user
    end

    it 'I can see the current market managers' do
      visit "/admin/markets/#{market.id}"

      click_link "Managers"

      within('.market-managers') do
        expect(page).to have_text(user.email)
      end
    end

    it 'I can add a market manager by email' do
      visit "/admin/markets/#{market.id}/managers"

      click_link 'Add Manager'

      fill_in 'Email', with: 'new-user@example.com'
      click_button 'Add Market Manager'

      expect(page).to have_text('new-user@example.com')
    end
  end

  describe 'as an admin' do
    let(:user) { create(:user, :admin) }
    let(:user2) { create(:user, role: 'user') }

    before(:each) do
      sign_in_as user

      user2.managed_markets << market
    end

    it 'I can see the current market managers' do
      visit "/admin/markets/#{market.id}"

      click_link "Managers"

      expect(page).to have_text(user2.email)
    end

    it 'I can add a market manager by email' do
      visit "/admin/markets/#{market.id}/managers"

      click_link 'Add Manager'

      fill_in 'Email', with: 'new-user@example.com'
      click_button 'Add Market Manager'

      expect(page).to have_text('new-user@example.com')

      click_link 'Sign Out'

      open_last_email

      visit_in_email("Join Local Orbit")

      expect(page).to have_content("Set your password")
    end

    it 'I can remove a current market manager' do
      visit "/admin/markets/#{market.id}/managers"

      expect(page).to have_text(user2.email)

      click_button 'Remove Manager'

      expect(page).to_not have_text(user2.email)
    end
  end
end
