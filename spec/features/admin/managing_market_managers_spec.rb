require "spec_helper"

describe "Admin Managing Market Managers" do
  let(:market) { create(:market) }

  describe 'as a normal user' do
    it 'I can not manage market managers' do
      sign_in_as create(:user, role: 'user')

      visit admin_market_managers_path(market)

      expect(page).to have_text("page you were looking for doesn't exist")
    end
  end

  describe 'as a market manager' do
    it 'I can not manage market managers' do
      user = create(:user, role: 'user')
      user.managed_markets << market

      sign_in_as user

      visit admin_market_managers_path(market)

      expect(page).to have_text("page you were looking for doesn't exist")
    end
  end

  describe 'as an admin' do
    let(:user) { create(:user) }
    let(:user2) { create(:user, role: 'user') }

    before(:each) do
      sign_in_as user

      user2.managed_markets << market
    end

    it 'I can see the current market managers' do
      visit "/admin/markets/#{market.id}"

      click_link "Managers"

      expect(page).to have_text("Market Managers for #{market.name}")
      expect(page).to have_text(user2.email)
    end

    it 'I can add a market manager by email' do
      visit "/admin/markets/#{market.id}/managers"

      click_link 'Add Manager'

      fill_in 'Email', with: 'new-user@example.com'
      click_button 'Add Market Manager'

      expect(page).to have_text("Market Managers for #{market.name}")
      expect(page).to have_text('new-user@example.com')
    end

    it 'I can remove a current market manager' do
      visit "/admin/markets/#{market.id}/managers"

      expect(page).to have_text(user2.email)

      click_button 'Remove Manager'

      expect(page).to have_text("Market Managers for #{market.name}")
      expect(page).to_not have_text(user2.email)
    end
  end
end