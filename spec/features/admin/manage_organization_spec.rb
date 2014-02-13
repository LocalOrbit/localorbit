require "spec_helper"

describe "admin manange organization" do
  let(:admin) { create(:user, :admin) }

  before do
    sign_in_as(admin)
  end

  it "create new organization" do
    create(:market, name: "Market 1")
    create(:market, name: "Market 2")

    click_link "Organizations"
    click_link "Add Organization"

    select "Market 2", from: "Market"
    fill_in "Name", with: "University of Michigan Farmers"
    fill_in "Who",  with: "Who Story"
    fill_in "How",  with: "How Story"

    click_button "Add Organization"

    expect(page).to have_content("University of Michigan Farmers has been created")
  end

  describe "locations" do
    let!(:organization) do
      create(:organization, name: "University of Michigan Farmers")
    end

    it "lists locations" do
      location = create(:location, :default_billing, :decorated, organization: organization)

      click_link "Organizations"
      click_link "University of Michigan Farmers"

      click_link "Addresses"

      locations = Dom::Admin::OrganizationLocation.all

      expect(locations.size).to eq(1)
      expect(locations.first.name_and_address).to include(location.name)
      expect(locations.first.default_billing).to be_checked
      expect(locations.first.default_shipping).not_to be_checked
    end

    it "add new location" do
      click_link "Organizations"
      click_link "University of Michigan Farmers"

      click_link "Addresses"
      click_link "Add New Address"

      fill_in "Location Name", with: "University of Michigan"
      fill_in "Address",       with: "500 S. State Street"
      fill_in "City",          with: "Ann Arbor"
      select  "Michigan",      from: "State"
      fill_in "Zip",           with: "34599"

      check "Default Billing?"

      click_button "Add Address"

      locations = Dom::Admin::OrganizationLocation.all

      expect(locations.size).to eq(1)
      expect(locations.first.name_and_address).to include("University of Michigan")
      expect(locations.first.name_and_address).to include("500 S. State Street, Ann Arbor, Michigan 34599")
      expect(locations.first.default_billing).to be_checked
      expect(locations.first.default_shipping).not_to be_checked

      expect(page).to have_content("Successfully added address University of Michigan")
    end

    it "removes a location" do
      create(:location, organization: organization)
      location_2 = create(:location, organization: organization)

      click_link "Organizations"
      click_link "University of Michigan Farmers"

      click_link "Addresses"

      locations = Dom::Admin::OrganizationLocation.all

      expect(locations.size).to eq(2)

      locations.last.remove!

      locations = Dom::Admin::OrganizationLocation.all

      expect(locations.size).to eq(1)
      expect(page).to have_content("Successfully removed the address(es) #{location_2.name}")
    end

    it "removes all locations", js: true do
      location_1 = create(:location, organization: organization)
      location_2 = create(:location, organization: organization)

      click_link "Organizations"
      click_link "University of Michigan Farmers"

      click_link "Addresses"

      locations = Dom::Admin::OrganizationLocation.all

      expect(locations.size).to eq(2)

      first(".check-all").set(true)
      click_button "Remove Checked"

      expect(Dom::Admin::OrganizationLocation.count).to eq(0)
      expect(page).to have_content("Successfully removed the address(es) #{location_2.name} and #{location_1.name}")
    end

    it "updates default address settings", js: true do
      create(:location, :default_billing,  organization: organization)
      create(:location, :default_shipping, organization: organization)

      click_link "Organizations"
      click_link "University of Michigan Farmers"

      click_link "Addresses"

      locations = Dom::Admin::OrganizationLocation.all

      expect(locations.first).to be_default_billing
      expect(locations.last).to  be_default_shipping

      locations.first.mark_default_shipping
      locations.last.mark_default_billing

      click_link "Save & Continue Editing"

      locations = Dom::Admin::OrganizationLocation.all

      expect(locations.last).to  be_default_billing
      expect(locations.first).to be_default_shipping
      expect(page).to have_content("Successfully updated default addresses")
    end
  end
end
