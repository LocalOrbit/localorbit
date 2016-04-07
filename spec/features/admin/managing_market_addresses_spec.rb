require "spec_helper"

describe "Admin Managing Markets" do
  let(:add_market_link_name) { "Add Market" }
  let!(:market) { create(:market) }

  before do
    switch_to_subdomain(market.subdomain)
  end

  describe "visiting the admin path without logging in" do
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
    #let!(:address2) { create(:market_address, market: market, default:true)} # here creates 44 e 8th st default

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
      expect(page).to have_text(address1.country)
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
      select "Canada", from: "Country"

      click_button "Add Address"

      expect(page).to have_text("New Address")
      expect(page).to have_text("123 Apple")
      expect(page).to have_text("Holland")
      expect(page).to have_text("MI")
      expect(page).to have_text("49423")
      expect(page).to have_text("616-123-4567")
      expect(page).to have_text("CA")
    end

    it "I can edit an existing address" do
      expect(page).to have_text(address1.name)

      click_link address1.name

      expect(page).to have_text("Default")
      expect(page).to have_text("Billing")
      expect(page).to have_text("Remit-to")

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

    it "deals with default address properly" do
      expect(page).to have_text "Add Address"

      click_link "Add Address"

      fill_in "Address Label", with: "New Address"
      fill_in "Address", with: "123 Apple"
      fill_in "City", with: "Holland"
      select "Michigan", from: "State"
      fill_in "Zip", with: "49423"
      fill_in "Phone", with: "616-123-4567"
      fill_in "Fax", with: "616-321-3214"
      check('market_address_default')
      check('market_address_billing')
      check('market_address_remit_to')
      click_button "Add Address"
      # add another
      click_link "Add Address"
      fill_in "Address Label", with: "New Address2"
      fill_in "Address", with: "123 Apple2"
      fill_in "City", with: "Albion"
      select "Michigan", from: "State"
      fill_in "Zip", with: "49423"
      fill_in "Phone", with: "616-123-4566"
      fill_in "Fax", with: "616-321-3215"
      check('market_address_default')
      check('market_address_billing')
      check('market_address_remit_to')
      click_button "Add Address"

      expect(market.addresses.visible.select{|mkt| mkt if mkt.default}.first.address).to eq("123 Apple2")
      expect(market.addresses.visible.select{|mkt| mkt if mkt.default}.length).to eq(1)
    end

    it "deals with billing address properly" do
      # have billing, submit new billing, check there's only one
      expect(page).to have_text "Add Address"

      click_link "Add Address"

      fill_in "Address Label", with: "New Address3"
      fill_in "Address", with: "123 Apple3"
      fill_in "City", with: "Holland"
      select "Michigan", from: "State"
      fill_in "Zip", with: "49423"
      fill_in "Phone", with: "616-123-4567"
      fill_in "Fax", with: "616-321-3214"
      check('market_address_billing')
      click_button "Add Address"
      # add another
      click_link "Add Address"
      fill_in "Address Label", with: "New Address4"
      fill_in "Address", with: "123 Apple4"
      fill_in "City", with: "Albion"
      select "Michigan", from: "State"
      fill_in "Zip", with: "49423"
      fill_in "Phone", with: "616-123-4566"
      fill_in "Fax", with: "616-321-3215"
      check('market_address_billing')
      click_button "Add Address"

      expect(market.reload.addresses.visible.select{|mktadr| mktadr if mktadr.billing}.first.address).to eq("123 Apple4")
      expect(market.reload.addresses.visible.select{|mktadr| mktadr if mktadr.billing}.length).to eq(1)
    end

    it "deals with remit-to address properly" do
      # have billing, submit new billing, check there's only one
      expect(page).to have_text "Add Address"

      click_link "Add Address"

      fill_in "Address Label", with: "New Address3"
      fill_in "Address", with: "123 Apple3"
      fill_in "City", with: "Holland"
      select "Michigan", from: "State"
      fill_in "Zip", with: "49423"
      fill_in "Phone", with: "616-123-4567"
      fill_in "Fax", with: "616-321-3214"
      check('market_address_remit_to')
      click_button "Add Address"
      # add another
      click_link "Add Address"
      fill_in "Address Label", with: "New Address4"
      fill_in "Address", with: "123 Apple4"
      fill_in "City", with: "Albion"
      select "Michigan", from: "State"
      fill_in "Zip", with: "49423"
      fill_in "Phone", with: "616-123-4566"
      fill_in "Fax", with: "616-321-3215"
      check('market_address_remit_to')
      click_button "Add Address"

      expect(market.reload.addresses.visible.select{|mktadr| mktadr if mktadr.remit_to}.first.address).to eq("123 Apple4")
      expect(market.reload.addresses.visible.select{|mktadr| mktadr if mktadr.remit_to}.length).to eq(1)
    end

    it "keeps correct boxes checked" do
      click_link "Add Address"

      fill_in "Address Label", with: "New Address"
      fill_in "Address", with: "123 Apple"
      fill_in "City", with: "Holland"
      select "Michigan", from: "State"
      fill_in "Zip", with: "49423"
      fill_in "Phone", with: "616-123-4567"
      fill_in "Fax", with: "616-321-3214"
      check('market_address_default')
      click_button "Add Address"
      click_link "New Address" # click on the label for address just added

      expect(find('#market_address_default')).to be_checked
      expect(find('#market_address_billing')).to_not be_checked
    end

    it "does not access soft-deleted default addresses as default" do
      subject = create(:market_address, name: "test", market: market, default: true, deleted_at: 1.day.ago)
      new_default = create(:market_address, name: "test2", market: market, default: true)
      expect(market.addresses.visible.select{|mkt| mkt if mkt.default}.first).to eq(new_default)
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
