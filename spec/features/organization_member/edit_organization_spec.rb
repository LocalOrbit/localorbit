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
    click_button 'Save Organization'

    expect(page).to have_content("Saved Famous Farm")
    expect(current_path).to eql(admin_organization_path(org))

    expect(find_field('Facebook').value).to eq("localorbit_fb")
    expect(find_field('Twitter').value).to eq("localorbit_twtr")
  end
end
