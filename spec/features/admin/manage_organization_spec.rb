require "spec_helper"

describe "admin manange organization" do
  let(:admin) { create(:user, :admin) }

  before do
    switch_to_main_domain
    sign_in_as(admin)
  end

  it "create new organization" do
    create(:market, name: "Market 1")
    create(:market, name: "Market 2")

    visit "/admin/organizations"
    click_link "Add Organization"

    select "Market 2", from: "Market"
    fill_in "Name", with: "University of Michigan Farmers"
    fill_in "Who",  with: "Who Story"
    fill_in "How",  with: "How Story"

    fill_in "Location Name", with: "Warehouse 1"
    fill_in "Address", with: "1021 Burton St."
    fill_in "City", with: "Orleans Twp."
    select "Michigan", from: "State"
    fill_in "Postal Code", with: "49883"
    fill_in "Phone", with: "616-555-9983"
    fill_in "Fax", with: "616-555-9984"

    click_button "Add Organization"

    expect(page).to have_content("University of Michigan Farmers has been created")
  end

  it "maintains market selection on form errors" do
    m1 = create(:market, name: "Market 1")
    m2 = create(:market, name: "Market 2")

    visit "/admin/organizations"
    click_link "Add Organization"

    select "Market 2", from: "Market"
    click_button "Add Organization"

    expect(page).to have_content("Name can't be blank")
    expect(find_field('Market').value).to eq(m2.id.to_s)
  end

  describe "locations" do
    let!(:organization) do
      create(:organization, name: "University of Michigan Farmers")
    end

    it "lists locations" do
      location = create(:location, :decorated, organization: organization)

      visit "/admin/organizations"
      click_link "University of Michigan Farmers"

      click_link "Addresses"

      locations = Dom::Admin::OrganizationLocation.all

      expect(locations.size).to eq(1)
      expect(locations.first.name_and_address).to include(location.name)
      expect(locations.first.default_billing).to be_checked
      expect(locations.first.default_shipping).to be_checked
    end

    describe "Adding a new location" do
      it "saves the location" do
        visit "/admin/organizations"
        click_link "University of Michigan Farmers"

        click_link "Addresses"
        click_link "Add New Address"

        fill_in "Location Name", with: "University of Michigan"
        fill_in "Address",       with: "500 S. State Street"
        fill_in "City",          with: "Ann Arbor"
        select  "Michigan",      from: "State"
        fill_in "Postal Code",   with: "34599"
        fill_in "Phone", with: "616-555-9983"
        fill_in "Fax", with: "616-555-9984"

        click_button "Add Address"

        locations = Dom::Admin::OrganizationLocation.all

        expect(locations.size).to eq(1)
        expect(locations.first.name_and_address).to include("University of Michigan")
        expect(locations.first.name_and_address).to include("500 S. State Street, Ann Arbor, MI 34599")
        expect(locations.first.default_billing).to be_checked
        expect(locations.first.default_shipping).to be_checked

        expect(page).to have_content("Successfully added address University of Michigan")
      end

      context "with invalid information" do
        it "shows error messages" do
          visit "/admin/organizations"
          click_link "University of Michigan Farmers"

          click_link "Addresses"
          click_link "Add New Address"

          click_button "Add Address"

          expect(page).to have_content("Location name can't be blank")
          expect(page).to have_content("Address can't be blank")
          expect(page).to have_content("City can't be blank")
          expect(page).to have_content("State can't be blank")
          expect(page).to have_content("Postal code can't be blank")
        end
      end
    end

    it "removes a location" do
      create(:location, organization: organization)
      location_2 = create(:location, organization: organization)

      visit "/admin/organizations"
      click_link "University of Michigan Farmers"

      click_link "Addresses"

      locations = Dom::Admin::OrganizationLocation.all

      expect(locations.size).to eq(2)

      location = locations.last
      location.remove!

      locations = Dom::Admin::OrganizationLocation.all

      expect(locations.size).to eq(1)
      expect(page).to have_content("Successfully removed the address(es) #{location.name}")
    end

    it "removes all locations", js: true do
      location_1 = create(:location, organization: organization)
      location_2 = create(:location, organization: organization)

      visit "/admin/organizations"
      click_link "University of Michigan Farmers"

      click_link "Addresses"

      locations = Dom::Admin::OrganizationLocation.all

      expect(locations.size).to eq(2)

      first(".check-all").set(true)
      click_button "Delete Selected"

      expect(Dom::Admin::OrganizationLocation.count).to eq(0)
      expect(page).to have_content("Successfully removed the address(es) #{location_2.name} and #{location_1.name}")
    end

    it "updates default address settings", js: true do
      create(:location, organization: organization)
      billing  = create(:location, organization: organization)
      shipping = create(:location, organization: organization)

      visit "/admin/organizations"
      click_link "University of Michigan Farmers"

      click_link "Addresses"

      locations = Dom::Admin::OrganizationLocation.all
      locations.each do |location|
        if location.name == billing.name
          location.mark_default_billing
        elsif location.name == shipping.name
          location.mark_default_shipping
        end
      end

      click_link "Save"

      locations = Dom::Admin::OrganizationLocation.all
      locations.each do |location|
        if location.name == billing.name
          expect(location).to be_default_billing
        elsif location.name == shipping.name
          expect(location).to be_default_shipping
        end
      end

      expect(page).to have_content("Successfully updated default addresses")
    end

    it "update location information" do
      create(:location, :default_billing, organization: organization, name: "Original Name")

      visit "/admin/organizations"
      click_link "University of Michigan Farmers"

      click_link "Addresses"

      location = Dom::Admin::OrganizationLocation.first
      location.edit

      fill_in "Location Name", with: "University of Michigan"
      click_button "Save Address"

      location = Dom::Admin::OrganizationLocation.first

      expect(location.name).to eq("University of Michigan")
      expect(page).to have_content("Successfully updated address University of Michigan")
    end
  end
end
