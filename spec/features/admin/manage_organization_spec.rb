require "spec_helper"

describe "admin manange organization", :vcr do
  let(:admin) { create(:user, :admin) }

  before do
    switch_to_main_domain
    sign_in_as(admin)
  end

  it "create new organization with multiple markets available", js: true do
    create(:market, name: "Market 1", default_allow_purchase_orders: true, default_allow_credit_cards: true, default_allow_ach: true)
    create(:market, name: "Market 2", allow_purchase_orders: false, default_allow_purchase_orders: false, default_allow_credit_cards: true, default_allow_ach: false)

    visit "/admin/organizations"
    click_link "Add Organization"

    check "Can sell products"
    expect(page).to have_content("Who")
    expect(page).to have_content("How")

    expect(page).to have_content("Select a market to see payment options")

    select "Market 1", from: "Market"

    expect(find_field("Allow purchase orders")).to be_checked
    expect(find_field("Allow credit cards")).to be_checked
    expect(find_field("Allow ACH")).to be_checked

    select "Market 2", from: "Market"

    check "Can sell products"
    expect(page).to have_content("Who")
    expect(page).to have_content("How")

    fill_in "Name", with: "University of Michigan Farmers"
    fill_in "Who",  with: "Who Story"
    fill_in "How",  with: "How Story"

    fill_in "Address Label", with: "Warehouse 1"
    fill_in "Address", with: "1021 Burton St."
    fill_in "City", with: "Orleans Twp."
    select "Michigan", from: "State"
    fill_in "Postal Code", with: "49883"
    fill_in "Phone", with: "616-555-9983"
    fill_in "Fax", with: "616-555-9984"

    expect(page).to_not have_field("Allow purchase orders")
    expect(find_field("Allow credit cards")).to be_checked
    expect(find_field("Allow ACH")).to_not be_checked

    click_button "Add Organization"

    expect(page).to have_content("University of Michigan Farmers has been created")
    expect(find_field("Organization is active")).to be_checked
  end

  it "should not see payment types that are disabled for the market", js: true do
    create(:market, name: "Market 1", allow_purchase_orders: false, allow_credit_cards: true, allow_ach: true)

    visit "/admin/organizations"
    click_link "Add Organization"

    check "Can sell products"
    expect(page).to have_content("Who")
    expect(page).to have_content("How")

    expect(page).to_not have_field("Allow purchase orders")
    expect(page).to have_field("Allow credit cards")
    expect(page).to have_field("Allow ACH")
  end


  it "create new organization", js: true do
    create(:market, name: "Market 1", default_allow_purchase_orders: true, default_allow_credit_cards: false, default_allow_ach: false)

    visit "/admin/organizations"
    click_link "Add Organization"

    check "Can sell products"
    expect(page).to have_content("Who")
    expect(page).to have_content("How")

    fill_in "Name", with: "University of Michigan Farmers"
    fill_in "Who",  with: "Who Story"
    fill_in "How",  with: "How Story"

    fill_in "Address Label", with: "Warehouse 1"
    fill_in "Address", with: "1021 Burton St."
    fill_in "City", with: "Orleans Twp."
    select "Michigan", from: "State"
    fill_in "Postal Code", with: "49883"
    fill_in "Phone", with: "616-555-9983"
    fill_in "Fax", with: "616-555-9984"

    expect(find("#organization_allow_purchase_orders")).to be_checked
    expect(find("#organization_allow_credit_cards")).to_not be_checked
    expect(find("#organization_allow_ach")).to_not be_checked

    click_button "Add Organization"

    expect(page).to have_content("University of Michigan Farmers has been created")
    expect(find_field("Organization is active")).to be_checked
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

        fill_in "Address Label", with: "University of Michigan"
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
      click_button("Delete Selected")

      expect(Dom::Admin::OrganizationLocation.count).to eq(0)
      expect(page).to have_content("Successfully removed the address(es) #{location_1.name} and #{location_2.name}")
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

      fill_in "Address Label", with: "University of Michigan"
      click_button "Save Address"

      location = Dom::Admin::OrganizationLocation.first

      expect(location.name).to eq("University of Michigan")
      expect(page).to have_content("Successfully updated address University of Michigan")
    end
  end

  context "sorting", :js do
    let!(:organization_a) { create(:organization, name: "A Organization", can_sell: false, created_at: '2014-01-01') }
    let!(:organization_b) { create(:organization, name: "B Organization", can_sell: true, created_at: '2013-01-01') }
    let!(:organization_c) { create(:organization, name: "C Organization", can_sell: false, created_at: '2012-01-01') }

    before do
      visit admin_organizations_path
    end

    context "by name" do
      it "ascending" do
        click_header("name")

        first = Dom::Admin::OrganizationRow.first
        expect(first.name).to have_content(organization_a.name)
      end

      it "descending" do
        click_header_twice("name")

        first = Dom::Admin::OrganizationRow.first
        expect(first.name).to have_content(organization_c.name)
      end
    end

    context "by registered" do
      it "ascending" do
        click_header("registered")

        first = Dom::Admin::OrganizationRow.first
        expect(first.name).to have_content(organization_c.name)
      end

      it "descending" do
        click_header_twice("registered")

        first = Dom::Admin::OrganizationRow.first
        expect(first.name).to have_content(organization_a.name)
      end
    end

    context "by can sell" do
      it "ascending" do
        click_header("can_sell")

        first = Dom::Admin::OrganizationRow.first
        expect(first.name).to have_content(organization_a.name)
      end

      it "descending" do
        click_header_twice("can_sell")

        first = Dom::Admin::OrganizationRow.first
        expect(first.name).to have_content(organization_b.name)
      end
    end
  end

  describe "Deleting an organization" do
    let!(:market) { create(:market) }

    context "single market membership" do
      let!(:seller) { create(:organization, :seller, name: "Holland Farms", markets:[market])}
      let!(:buyer) { create(:organization, name: "Hudsonville Restraunt", markets: [market])}

      it "removes the organization from the organizations list" do
        visit admin_organizations_path
        expect(page).to have_content("Holland Farms")

        holland_farms = Dom::Admin::OrganizationRow.find_by_name("Holland Farms")

        within(holland_farms.node) do
          click_link "Delete"
        end

        expect(page).to have_content("Removed Holland Farms")

        holland_farms = Dom::Admin::OrganizationRow.find_by_name("Holland Farms")
        expect(holland_farms.market).to_not have_content(market.name)
      end
    end

    context "multi-market membership", :js do
      let!(:market2) { create(:market) }

      let!(:seller) { create(:organization, :seller, name: "Holland Farms", markets:[market, market2])}
      let!(:buyer) { create(:organization, name: "Hudsonville Restraunt", markets: [market])}

      it "removes the organization from the organizations list" do
        visit admin_organizations_path
        expect(page).to have_content("Holland Farms")

        holland_farms = Dom::Admin::OrganizationRow.find_by_name("Holland Farms")

        within(holland_farms.node) do
          click_link "Delete"
        end

        expect(page).to have_content("Remove Organization from Markets")
        sleep(1)
        expect(Dom::Admin::MarketMembershipRow.count).to eql(2)

        Dom::Admin::MarketMembershipRow.find_by_name(market.name).check
        click_button "Remove Membership(s)"

        expect(page).to have_content("Removed Holland Farms")

        holland_farms = Dom::Admin::OrganizationRow.find_by_name("Holland Farms")
        expect(holland_farms.market).to have_content(market2.name)
        expect(holland_farms.market).to_not have_content(market.name)
      end
    end
  end
end
