require 'spec_helper'

describe 'Market Manager managing delivery schedules' do
  let!(:user) { create(:user, :market_manager) }
  let!(:market) { user.managed_markets.first }
  let!(:address) { create(:market_address, market: market) }

  before do
    sign_in_as user
    click_link 'Markets'
    click_link market.name
    click_link 'Deliveries'
  end

  it 'adding a new schedule' do
    click_link 'Add Delivery'

    select 'Tuesday', from: 'Day'
    fill_in 'Order cutoff', with: '6'
    select 'Direct to customer', from: 'Fulfillment method'
    select '7:15 AM', from: 'Seller delivery start'
    select '11:30 AM', from: 'Seller delivery end'

    click_button 'Save Delivery'

    expect(page).to have_content('Saved delivery schedule')
  end
end
