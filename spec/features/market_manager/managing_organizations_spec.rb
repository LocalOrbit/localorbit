require "spec_helper"

describe "A Market Manager" do
  let(:market_manager) { create :user, :market_manager }
  let(:market) { market_manager.managed_markets.first }

  before(:each) do
    sign_in_as market_manager
  end

  it "can add an organization" do
    click_link 'Organizations'
    click_link 'Add Organization'

    fill_in 'Name', with: 'Famous Farm'
    check 'Can sell product'
    click_button 'Add Organization'

    expect(page).to have_content('Famous Farm has been created')
  end

  context "adding an organization with a blank name" do
    it "doesn't add the new organization" do
      click_link 'Organizations'
      click_link 'Add Organization'

      fill_in 'Name', with: ''
      click_button 'Add Organization'

      expect(page).to have_content("Name can't be blank")
    end
  end
end
