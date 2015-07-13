require "spec_helper"

describe "Admin Managing Markets" do
  let(:add_market_link_name) { "Add Market" }
  let!(:market) { create(:market) }

  before do
    switch_to_subdomain(market.subdomain)
  end

  describe "visiting the admin path without loggin in" do
    it "redirects a user to the login pages" do
      visit admin_market_addresses_path(market)

      expect(page).to have_content("You need to sign in")
    end
  end

  describe "as a normal user" do
    let!(:normal_user) { create(:user, role: "user") }
    let!(:org) { create(:organization, markets: [market], users: [normal_user]) }

    it "users can not manage addresses" do
      sign_in_as normal_user

      visit admin_market_addresses_path(market)

      expect(page).to have_text("page you were looking for doesn't exist")
    end
  end

  describe "as a market manager" do
    let!(:user) { create(:user, role: "user") }
    let!(:address1) { create(:market_address, market: market) }

    before do
      user.managed_markets << market
      sign_in_as user
      visit admin_market_addresses_path(market)
    end

    it "I can see a markets addresses" do
      expect(page).to have_text(address1.name)
      expect(page).to have_text(address1.address)
      expect(page).to have_text(address1.city)
      expect(page).to have_text(address1.state)
      expect(page).to have_text(address1.zip)
    end

    it "I can delete an address from the index" do
      expect(page).to have_text(address1.name)

      page.find(".delete-address").click

      expect(page).to_not have_text(address1.name)
    end

    it "I can add a new address" do
      expect(page).to have_text "Add Address"

      click_link "Add Address"

      fill_in "Address Label", with: "New Address"
      fill_in "Address", with: "123 Apple"
      fill_in "City", with: "Holland"
      select "Michigan", from: "State"
      fill_in "Zip", with: "49423"
      fill_in "Phone", with: "616-123-4567"
      fill_in "Fax", with: "616-321-3214"

      click_button "Add Address"

      expect(page).to have_text("New Address")
      expect(page).to have_text("123 Apple")
      expect(page).to have_text("Holland")
      expect(page).to have_text("MI")
      expect(page).to have_text("49423")
      expect(page).to have_text("616-123-4567")
    end

    it "I can edit an existing address" do
      expect(page).to have_text(address1.name)

      click_link address1.name

      fill_in "Address Label", with: "Edited Address"

      click_button "Update Address"

      expect(page).to have_text("Edited Address")
    end

    it "I can remove an existing address" do
      expect(page).to have_text(address1.name)

      click_link address1.name

      click_link "Delete Address"

      expect(page).to_not have_text(address1.name)
    end

    it "handles empty labels when trying to create a new address" do
      click_link address1.name

      fill_in "Address Label", with: ""

      click_button "Update Address"
      expect(page).to have_text("Default Address")
    end

    it "provides some Canadian province choices" do
      click_link "Add Address"
      select "Quebec", from: "State"
      select "British Columbia", from: "State"
      select "Ontario", from: "State"
    end
  end

  describe "as an admin" do
    let!(:user) { create(:user, :admin) }
    let!(:address1) { create(:market_address, market: market) }

    before :each do
      sign_in_as user
    end

    it "I can see a markets addresses" do
      visit admin_market_addresses_path(market)

      expect(page).to have_text(address1.name)
      expect(page).to have_text(address1.address)
      expect(page).to have_text(address1.city)
      expect(page).to have_text(address1.state)
      expect(page).to have_text(address1.zip)
    end

  end
end
