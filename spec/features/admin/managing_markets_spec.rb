require "spec_helper"

describe "Admin Managing Markets" do
  describe 'as a normal user' do
    it 'users can not manage markets' do
      sign_in_as FactoryGirl.create(:user, role: 'user')

      visit '/admin/markets'

      expect(page).to have_text("page you were looking for doesn't exist")
    end
  end

  describe 'as an admin' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:market) { FactoryGirl.create(:market) }

    before :each do
      sign_in_as user
    end

    it 'only admins or market managers can manage markets'

    it 'an admin can see a list of markets' do
      @market2 = FactoryGirl.create(:market)
      visit '/admin/markets'

      expect(page).to have_text('Markets')
      expect(page).to have_text(market.name)
      expect(page).to have_text(@market2.name)
    end

    it 'an admin can see details for a single market' do
      @market2 = FactoryGirl.create(:market)

      visit '/admin/markets'

      click_link market.name

      expect(page).to have_text(market.name)
      expect(page).to_not have_text(@market2.name)
    end

    it 'an admin can add a market' do
      visit '/admin/markets'

      click_link 'Add Market'

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
