require "spec_helper"

describe "Admin Managing Markets" do
  let(:add_market_link_name) { 'Add Market' }
  let!(:market1) { create(:market) }

  describe "visiting the admin path without loggin in" do
    it "redirects a user to the login pages" do
      visit admin_market_addresses_path(market1)

      expect(page).to have_content("You need to sign in")
    end
  end

  describe 'as a normal user' do
    let!(:normal_user) { create(:user, role: 'user') }

    it 'users can not manage addresses' do
      sign_in_as normal_user

      visit admin_market_addresses_path(market1)

      expect(page).to have_text("page you were looking for doesn't exist")
    end
  end

  describe 'as a market manager' do
    let!(:user) { create(:user, role: 'user') }
    let!(:address1) { create(:market_address, market: market1) }

    before :each do
      sign_in_as user

      user.managed_markets << market1
      
      visit admin_market_addresses_path(market1)
    end

    it 'I can see a markets addresses' do
      expect(page).to have_text(address1.name)
      expect(page).to have_text(address1.address)
      expect(page).to have_text(address1.city)
      expect(page).to have_text(address1.state)
      expect(page).to have_text(address1.zip)
    end

    it 'I can add a new address' do
      expect(page).to have_text 'Add Address'

      click_link 'Add Address'

      fill_in 'Name', with: 'New Address'
      fill_in 'Address', with: '123 Apple'
      fill_in 'City', with: 'Holland'
      fill_in 'State', with: 'MI'
      fill_in 'Zip', with: '49423'

      click_button 'Add Address'

      expect(page).to have_text('New Address')
    end

    it 'I can edit an existing address' do
      expect(page).to have_text(address1.name)

      click_link address1.name

      fill_in 'Name', with: 'Edited Address'

      click_button 'Update Address'

      expect(page).to have_text('Edited Address')
    end

    it 'I can remove an existing address' do
      expect(page).to have_text(address1.name)

      click_link address1.name

      click_link "Delete Address"

      expect(page).to_not have_text(address1.name)
    end

    it 'displays errors when trying to create a new address' do
      click_link 'Add Address'

      click_button 'Add Address'

      expect(page).to have_text("Name can't be blank")
    end

    it 'displays errors when trying to create a new address' do
      click_link address1.name

      fill_in 'Name', with: ''

      click_button 'Update Address'

      expect(page).to have_text("Name can't be blank")
    end
  end

  describe 'as an admin' do
    let!(:user) { create(:user, :admin) }
    let!(:address1) { create(:market_address, market: market1) }

    before :each do
      sign_in_as user
    end
    
    it 'I can see a markets addresses' do
      visit admin_market_addresses_path(market1)

      expect(page).to have_text(address1.name)
      expect(page).to have_text(address1.address)
      expect(page).to have_text(address1.city)
      expect(page).to have_text(address1.state)
      expect(page).to have_text(address1.zip)
    end

  end
end
