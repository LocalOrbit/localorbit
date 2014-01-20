require "spec_helper"

describe "Admin Managing Markets" do
  let(:add_market_link_name) { 'Add Market' }

  describe 'as a normal user' do
    it 'users can not manage markets' do
      sign_in_as create(:user, role: 'user')

      visit admin_markets_path

      expect(page).to have_text("page you were looking for doesn't exist")
    end
  end

  describe 'as a market manager' do
    let!(:user) { create(:user, role: 'user') }
    let!(:market1) { create(:market) }
    let!(:market2) { create(:market) }

    before :each do
      sign_in_as user

      user.managed_markets << market1
      user.managed_markets << market2
    end

    it 'I can see my markets' do
      visit '/admin/markets'

      expect(page).to have_text('Markets')
      expect(page).to have_text(market1.name)
      expect(page).to have_text(market2.name)
    end

    it 'I can see the details for each of my markets' do
      visit '/admin/markets'

      click_link market1.name

      expect(page).to have_text(market1.name)
      expect(page).to_not have_text(market2.name)
    end

    it 'I can modify a market' do
      visit '/admin/markets'
      click_link market1.name

      expect(page).to have_text('Jill Smith')

      click_link 'Edit Market'

      fill_in 'Contact name', with: 'Jane Smith'

      click_button 'Update Market'

      expect(page).to have_text('Edit Market')
      expect(page).to have_text('Jane Smith')
    end

    it 'I can activate a market' do
      market1.update_attribute(:active, true)

      visit "/admin/markets/#{market1.id}"

      expect(page).to have_text('Active? Yes')

      click_button 'Deactivate'

      expect(page).to have_text('Active? No')
    end

    it 'I can deactivate a market' do
      visit "/admin/markets/#{market1.id}"

      expect(page).to have_text('Active? No')

      click_button 'Activate'

      expect(page).to have_text('Active? Yes')
    end

    it 'I can not add a market' do
      visit '/admin/markets'

      expect(page).to_not have_text(add_market_link_name)

      visit new_admin_market_path

      expect(page).to have_text("page you were looking for doesn't exist")
    end

    describe 'with additional markets' do
      let!(:market3) { create(:market) }

      it 'I do not see markets I am not managing in my list' do
        visit '/admin/markets'

        expect(page).to_not have_text(market3.name)
      end

      it 'I can not see the details for a market I am not managing' do
        visit admin_market_path(market3)

        expect(page).to have_text("page you were looking for doesn't exist")
      end

      it 'I can not modify a market I am not managing' do
        visit edit_admin_market_path(market3)

        expect(page).to have_text("page you were looking for doesn't exist")
      end
    end
  end

  describe 'as an admin' do
    let!(:user) { create(:user) }
    let!(:market) { create(:market) }

    before :each do
      sign_in_as user
    end

    it 'an admin can see a list of markets' do
      visit '/dashboard'

      @market2 = create(:market)
      click_link 'Markets'

      expect(page).to have_text('Markets')
      expect(page).to have_text(market.name)
      expect(page).to have_text(@market2.name)
    end

    it 'an admin can see details for a single market' do
      @market2 = create(:market)

      visit '/admin/markets'

      click_link market.name

      expect(page).to have_text(market.name)
      expect(page).to_not have_text(@market2.name)
    end

    it 'an admin can add a market' do
      visit '/admin/markets'

      click_link add_market_link_name

      fill_in 'Name',          with: 'Holland Farmers'
      fill_in 'Subdomain',     with: 'holland-farmers'
      select  '(GMT-05:00) Eastern Time (US & Canada)', from: 'Timezone'
      fill_in 'Contact name',  with: 'Jill Smith'
      fill_in 'Contact email', with: 'jill@smith.com'
      fill_in 'Contact phone', with: '616-222-2222'
      fill_in 'Facebook',      with: 'https://www.facebook.com/hollandfarmers'
      fill_in 'Twitter',       with: '@hollandfarmers'
      fill_in 'Profile',       with: 'Some interesting info about Holland Farmers'
      fill_in 'Policies',      with: 'Something no one will pay attention to'

      click_button 'Add Market'

      expect(page).to have_text('Holland Farmers')
      expect(page).to have_text('Jill Smith')
      expect(page).to have_text('@hollandfarmers')
    end

    it 'an admin can modify a market' do
      visit '/admin/markets'
      click_link market.name

      expect(page).to have_text('Jill Smith')

      click_link 'Edit Market'

      fill_in 'Contact name', with: 'Jane Smith'

      click_button 'Update Market'

      expect(page).to have_text('Edit Market')
      expect(page).to have_text('Jane Smith')
    end

    it 'an admin can mark an active market as inactive' do
      market.update_attribute(:active, true)

      visit "/admin/markets/#{market.id}"

      expect(page).to have_text('Active? Yes')

      click_button 'Deactivate'

      expect(page).to have_text('Active? No')
    end

    it 'an admin can mark an inactive market as active' do
      visit "/admin/markets/#{market.id}"

      expect(page).to have_text('Active? No')

      click_button 'Activate'

      expect(page).to have_text('Active? Yes')
    end
  end
end
