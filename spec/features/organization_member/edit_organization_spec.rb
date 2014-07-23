require 'spec_helper'


describe "An organization member" do
  let(:member) { create(:user, role: 'user') }
  let(:org) { create(:organization, users: [member]) }
  let(:market)  { create(:market, organizations: [org]) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as member
  end

  it "can edit an organization they belong to" do
    visit "/admin/organizations"
    click_link org.name

    # This should only be controlled by a Market Manager
    expect(page).to_not have_content("Can sell product")

    fill_in 'Name', with: 'Famous Farm'
    fill_in 'Facebook', with: 'localorbit_fb'
    fill_in 'Twitter',  with: 'localorbit_twtr'

    check "organization[display_facebook]"
    check "organization[display_twitter]"

    click_button 'Save Organization'

    expect(page).to have_content("Saved Famous Farm")
    expect(current_path).to eql(admin_organization_path(org))

    expect(find_field('Facebook').value).to eq("localorbit_fb")
    expect(find_field('Twitter').value).to eq("localorbit_twtr")

    expect(find_field('organization[display_facebook]')).to be_checked
    expect(find_field('organization[display_twitter]')).to be_checked
  end

  it "can not change their active status" do
    expect(page).to_not have_field("Organization is active")
  end

  describe "A buying organization" do
    let(:org) { create(:organization, users: [member], can_sell: false) }

    it "hides profile information" do
      visit "/admin/organizations"
      click_link org.name

      expect(page).not_to have_content("Facebook")
      expect(page).not_to have_content("Twitter")
      expect(page).not_to have_content("Display Feed on Profile Page")
      expect(page).not_to have_content("Profile photo")
      expect(page).not_to have_content("Who")
      expect(page).not_to have_content("How")
      expect(page).not_to have_content("Allowed payment methods")
    end
  end

  describe "A selling organization" do
    let(:org) { create(:organization, users: [member], can_sell: true) }

    it "shows profile information" do
      visit "/admin/organizations"
      click_link org.name

      expect(page).to have_content("Facebook")
      expect(page).to have_content("Twitter")
      expect(page).to have_content("Display Feed on Profile Page")
      expect(page).to have_content("Profile photo")
      expect(page).to have_content("Who")
      expect(page).to have_content("How")
      expect(page).to have_content("Show on Profile page")
    end
  end
end
