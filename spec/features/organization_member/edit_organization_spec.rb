require 'spec_helper'


describe "An organization member" do
  let(:member) { create(:user, role: 'user') }
  let(:org) { create(:organization) }

  before(:each) do
    org.users << member
    sign_in_as member
  end

  it "can edit an organization they belong to" do
    click_link "Organizations"
    click_link org.name
    click_link "Edit Organization"

    # This should only be controlled by a Market Manager
    expect(page).to_not have_content("Can sell product")

    fill_in 'Name', with: 'Famous Farm'
    click_button 'Save Organization'

    expect(page).to have_content("Saved Famous Farm")
    expect(current_path).to eql(admin_organization_path(org))
  end
end
