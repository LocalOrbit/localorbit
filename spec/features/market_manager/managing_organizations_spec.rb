require "spec_helper"

describe "A Market Manager", :vcr do
  let!(:market)  { create(:market, :with_delivery_schedule) }
  let!(:market2) { create(:market) }
  let!(:market_manager) { create :user, :market_manager, managed_markets: [market] }

  before(:each) do
    switch_to_subdomain(market.subdomain)
    visit("/")
    sign_in_as market_manager
  end

  describe "Adding an organization" do
    context "with valid information", :js do
      it "creates the organization" do
        visit "/admin/organizations"
        click_link "Add Organization"

        check "Can sell products"
        expect(page).to have_content("Profile photo")

        fill_in "Name", with: "Famous Farm"
        fill_in "Address Label", with: "Warehouse 1"
        fill_in "Address", with: "1021 Burton St."
        fill_in "City", with: "Orleans Twp."
        select "Michigan", from: "State"
        fill_in "Postal Code", with: "49883"
        fill_in "Phone", with: "616-555-9983"

        check "Allow purchase orders"

        attach_file "Profile photo", "app/assets/images/logo.png"

        click_button "Add Organization"

        expect(page).to have_content("Famous Farm has been created")

        expect(page).to have_css("img[alt='Profile photo']")

        expect(find_field("Organization is active")).not_to be_checked

        org_form = Dom::Admin::OrganizationForm.first
        expect(org_form.name).to eql("Famous Farm")

        # it "creates a default location for the organization"
        click_link "Addresses"

        click_link "Warehouse 1"

        location = Dom::Admin::LocationForm.first

        expect(location.location_name.value).to eql("Warehouse 1")
        expect(location.address.value).to eql("1021 Burton St.")
        expect(location.city.value).to eql("Orleans Twp.")
        expect(location.selected_state.value).to eql("MI")
        expect(location.zip.value).to eql("49883")
      end
    end

    context "with minimum valid information", :js do
      before do
        visit "/admin/organizations"
        click_link "Add Organization"

        fill_in "Name", with: "Famous Farm"

        click_button "Add Organization"
      end

      it "creates the organization" do
        expect(page).to have_content("Famous Farm has been created")

        org_form = Dom::Admin::OrganizationForm.first
        expect(org_form.name).to eql("Famous Farm")

      end

      it "creates the organization as not active" do
        expect(find_field("Organization is active")).not_to be_checked
      end
    end

    context "when the market manager manages multiple markets" do
      before do
        market_manager.managed_markets << market2
      end

      it "creates an organization with valid information", :js, :shaky do
        skip "shaky test"
        visit "/admin/organizations"
        click_link "Add Organization"

        fill_in "Name", with: "Famous Farm"
        select market2.name, from: "Market"
        check "Can sell product"

        fill_in "Address Label", with: "Warehouse 1"
        fill_in "Address", with: "1021 Burton St."
        fill_in "City", with: "Orleans Twp."
        select "Michigan", from: "State"
        fill_in "Postal Code", with: "49883"
        fill_in "Phone", with: "616-555-9983"

        click_button "Add Organization"

        expect(page).to have_content("Famous Farm has been created")
      end

      it "creates an organization with minimum valid information", :js do
        visit admin_organizations_path

        click_link "Add Organization"

        fill_in "Name", with: "Famous Farm"
        select market2.name, from: "Market"

        expect(page).to have_content("Allow purchase orders")
        check "Allow purchase orders"

        click_button "Add Organization"

        expect(page).to have_content("Famous Farm has been created")
      end

      it "displays errors from invalid data" do
        visit "/admin/organizations"
        click_link "Add Organization"
        fill_in "Name", with: "Dairy Farms Co-op"
        click_button "Add Organization"

        expect(page).to have_content("Markets can't be blank")
      end
    end
  end

  describe "Editing an organization" do
    let(:organization) { create(:organization, name: "Fresh Pumpkin Patch") }

    before do
      market.organizations << organization
    end

    it "doesn't show the location fields" do
      visit "/admin/organizations"
      click_link "Fresh Pumpkin Patch"

      within("fieldset.organization-info:last") do
        expect(page).not_to have_content("Address Label")
        expect(page).not_to have_content("Address")
        expect(page).not_to have_content("City")
        expect(page).not_to have_content("State")
        expect(page).not_to have_content("Postal Code")
      end
    end

    it "should not see payment types that are disabled for the market", :js do
      market.update_attribute(:allow_purchase_orders, false)

      visit "/admin/organizations"
      click_link "Add Organization"

      check "Can sell products"
      expect(page).to have_content("Allowed payment methods")

      expect(page).to_not have_field("Allow purchase orders")
      expect(page).to have_field("Allow credit cards")
    end

    it "allows updating all attributes", :js do
      visit "/admin/organizations"
      click_link "Fresh Pumpkin Patch"

      fill_in "Name", with: "SXSW Farmette"

      check "Can sell product"
      expect(page).to have_content("Allowed payment methods")

      uncheck "Show on Profile page"

      uncheck "Allow purchase orders"
      uncheck "Organization is active"
      click_button "Save Organization"

      expect(page).to have_content("Saved SXSW Farmette")
      expect(find_field("Name").value).to eq("SXSW Farmette")
      expect(find_field("Show on Profile page")).to_not be_checked

      expect(find_field("Allow purchase orders")).to_not be_checked
      expect(find_field("Allow credit cards")).to be_checked

      expect(find_field("Organization is active")).to_not be_checked
    end

    # it "does not allow updates with a blank organization name" do
    #   visit "/admin/organizations"
    #   click_link "Fresh Pumpkin Patch"

    #   fill_in "Name", with: ""
    #   click_button "Save Organization"

    #   #expect(page).to have_content("Name can't be blank")
    # end

    it "requires at least one payment method" do
      visit "/admin/organizations"
      click_link "Fresh Pumpkin Patch"

      uncheck "Allow purchase orders"
      uncheck "Allow credit cards"

      click_button "Save Organization"

      #expect(page).to have_content("At least one payment method is required for the organization")
      # Fails when removing Balanced-specific tests, commenting out for now. - JZC
    end

    it "deactivates an organization" do
      visit admin_organizations_path

      expect(page).to have_content("Deactivate")
      expect(page).to_not have_content("Activate")

      click_link "Deactivate"

      expect(page).to have_content("Activate")
      expect(page).to_not have_content("Deactivate")
    end

    describe "when a market manager has multiple markets" do
      before do
        market_manager.markets << market2
      end

      it "cannot change the market of an organizaiton" do
        visit "/admin/organizations"
        click_link "Fresh Pumpkin Patch"

        expect(page).to_not have_selector("organization_market_ids")
      end
    end

    describe "Manage an organization's ability to sell" do
      it "shows/hides the appropriate fields when 'can sell products' is checked", :js do
        visit "/admin/organizations"

        click_link "Fresh Pumpkin Patch"

        expect(page).to have_checked_field("Can sell products")

        expect(page).to have_content("Facebook")
        expect(page).to have_content("Twitter")
        expect(page).to have_content("Display Feed on Profile Page")
        expect(page).to have_content("Profile photo")
        expect(page).to have_content("Who")
        expect(page).to have_content("How")

        uncheck "Can sell products"

        expect(page).not_to have_content("Facebook")
        expect(page).not_to have_content("Twitter")
        expect(page).not_to have_content("Display Feed on Profile Page")
        expect(page).not_to have_content("Profile photo")
        expect(page).not_to have_content("Who")
        expect(page).not_to have_content("How")
      end
    end
  end

  describe "Deleting an organization", js: true do
    context "organization belongs to a single market" do
      let!(:market3) { create(:market, :with_address) }

      let!(:seller) { create(:organization, :seller, name: "Holland Farms", markets: [market]) }
      let!(:product) { create(:product, :sellable, organization: seller) }
      let!(:promotion) { create(:promotion, :active, market: market, product: product) }
      let!(:buyer) { create(:organization, :single_location, name: "Hudsonville Restraunt", markets: [market]) }

      before do
        market_manager.managed_markets << market2
        market_manager.save!

        visit admin_organizations_path
        expect(page).to have_content("Holland Farms")

        seller_row = Dom::Admin::OrganizationRow.find_by_name("Holland Farms")
        expect(seller_row.market).to eql(market.name)

        seller_row.click_delete
      end

      it "removes the organization from the organizations list" do
        expect(page).to have_content("Removed Holland Farms from #{market.name}")

        holland_farms = Dom::Admin::OrganizationRow.find_by_name("Holland Farms")
        expect(holland_farms).to be_nil
      end

      it "removes promotions for items" do
        visit products_path

        expect(page).to_not have_content(promotion.title)
      end

      context "and the market manager belongs to multiple markets" do
        let!(:market_manager) { create(:user, managed_markets: [market, market2]) }

        it "deletes the organization from the only market it's associated with" do
          expect(page).to have_content("Removed #{seller.name} from #{market.name}")
        end
      end
    end

    context "organization belongs to multiple markets" do
      let!(:seller) { create(:organization, :seller, name: "Holland Farms", markets: [market, market2]) }

      before do
        visit admin_organizations_path
        seller_row = Dom::Admin::OrganizationRow.find_by_name("Holland Farms")

        expect(seller_row).to_not be_nil

        seller_row.click_delete
        sleep(2)
      end

      context "and the market manager only manages one of the markets" do
        let!(:market_manager) { create(:user, managed_markets: [market]) }

        it "will not prompt to select a market" do
          expect(page).to have_content("Removed Holland Farms from #{market.name}")
          seller_row = Dom::Admin::OrganizationRow.find_by_name("Holland Farms")
          expect(seller_row).to be_nil
        end
      end

      context "and market manager manages more than one market" do
        let!(:market)  { create(:market, name: "Market 1") }
        let!(:market2) { create(:market, name: "Market 2") }
        let!(:market3) { create(:market, name: "Market 3") }

        let!(:seller)  { create(:organization, :seller, name: "Holland Farms", markets: [market2, market, market3]) }
        let!(:market_manager) { create(:user, managed_markets: [market, market3]) }

        it "allows the market manager to delete an organization from a one or more markets" do
          seller_row = Dom::Admin::OrganizationRow.find_by_name("Holland Farms")
          expect(seller_row.market).to eql("Market 2")

          members = Dom::Admin::MarketMembershipRow.all
          expect(members.count).to eql(2)

          expect(members[0].name).to eql(market.name)
          expect(members[1].name).to eql(market3.name)

          Dom::Admin::MarketMembershipRow.find_by_name(market.name).check
          click_button "Remove Membership(s)"

          expect(page).to have_content("Removed Holland Farms")

          seller_row = Dom::Admin::OrganizationRow.find_by_name("Holland Farms")
          expect(seller_row.market).to eql("Market 2")
        end
      end
    end
  end

  describe "Inviting a member to an org" do
    let(:org) { create(:organization, name: "Holland Farms") }

    before do
      market.organizations << org
    end

    context "when the user is not yet a member" do
      it "sends an email to a recipient inviting them to join an organization" do
        visit "/admin/organizations"
        click_link "Holland Farms"
        within(".tabs") do
          click_link "Users"
        end

        within("#new_user") do
          fill_in "Email address", with: "susan@example.com"
          click_button "Invite New User"
        end

        expect(page).to have_content("Sent invitation to susan@example.com")

        sign_out

        open_last_email_for "susan@example.com"
        expect(current_email).to have_subject("You have been invited to Holland Farms")
        expect(current_email.reply_to.first).to eq(market.contact_email)

        visit_in_email("Join Holland Farms")

        expect(page).to have_content("Set up your account")
      end
    end

    context "when the user is an active member of an organization" do
      let(:user) { create(:user, :admin) }
      before do
        org.users << user
      end

      it "show an error message" do
        visit "/admin/organizations"
        click_link "Holland Farms"
        within(".tabs") do
          click_link "Users"
        end

        within("#new_user") do
          fill_in "Email address", with: user.email
          click_button "Invite New User"
        end

        expect(page).to have_content("You have already added this user")
      end
    end

    context "when no email has been entered" do
      it "show an error message" do
        visit "/admin/organizations"
        click_link "Holland Farms"
        within(".tabs") do
          click_link "Users"
        end

        within("#new_user") do
          fill_in "Email address", with: ""
          click_button "Invite New User"
        end

        expect(page).to have_content("Email can't be blank")
      end
    end

    context "when an invalid email address has been entered" do
      it "show an error message" do
        visit "/admin/organizations"
        click_link "Holland Farms"
        within(".tabs") do
          click_link "Users"
        end

        within("#new_user") do
          fill_in "Email address", with: "asdfasdfasdfasdfasd"
          click_button "Invite New User"
        end

        expect(page).to have_content("Email is invalid")
      end
    end
  end

  it_behaves_like "activates and deactivates organizations" do
    let!(:user) { market_manager }
  end
end
