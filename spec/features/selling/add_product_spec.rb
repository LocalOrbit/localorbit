require "spec_helper"

describe "Adding a product", chosen_js: true do
  def fill_in_required_fields(select=:without_chosen)
    fill_in "Product Name", with: "Red Grapes"
    fill_in "Short description", with: "Grapes are yummy!"

    case select
    when :without_chosen
      select "Apples / Macintosh Apples", from: "Category"
      select "Pound", from: "Unit"
    when :with_chosen
      select_from_chosen "Grapes / Red Grapes", from: "Category"
      select_from_chosen "Pound", from: "Unit"
    end
  end

  let!(:user)                  { create(:user) }
  let!(:market)                { create(:market, :with_addresses) }
  let!(:aggregation_point)     { create(:market_address, market: market, name: "Aggregation Point", address: "1123 Grand Rd.", city: "Appleton", state: "WI", zip: "83992") }
  let!(:org)                   { create(:organization, :seller, :single_location, markets: [market], who_story: "We sell products", how_story: "We sell products very carefully") }
  let(:stub_warning_pricing)   { "Your product will not appear in the Shop until you add pricing" }
  let(:stub_warning_inventory) { "Your product will not appear in the Shop until you add inventory" }
  let(:stub_warning_both)      { "Your product will not appear in the Shop until you add inventory, and add pricing" }
  let(:organization_label)     { "Product Organization" }

  let!(:inactive_seller) { create(:organization, :seller, markets: [market], active: false) }

  let!(:mondays_schedule) { create(:delivery_schedule, market: market, day: 1, require_delivery: true) }
  let(:monday_schedule_description) { "Mondays from 7:00 AM to 11:00 AM direct to customer. (required)" }
  # This is the schedule we'll model after the Appleton bug
  # Seller fulfillment location is what will show for the seller
  let!(:tuesdays_schedule) do
    create(:delivery_schedule, :hub_to_buyer,
      seller_fulfillment_location: aggregation_point,
      market: market,
      day: 2,
      seller_delivery_start: "7:00 AM",
      seller_delivery_end: "9:00 AM",
      buyer_day: 2,
      buyer_pickup_start: "8:30 AM",
      buyer_pickup_end: "10:00 AM"
    )
  end
  let(:tuesday_schedule_description) { "Tuesdays from 7:00 AM to 9:00 AM at 1123 Grand Rd. Appleton, WI 83992. For Buyer pick up/delivery Tuesdays from 8:30 AM to 10:00 AM." }

  let!(:wed_thu_schedule) do
    create(:delivery_schedule, :buyer_pickup,
      market: market,
      day: 3,
      seller_delivery_start: "5:30 PM",
      seller_delivery_end: "8:15 PM",
      buyer_day: 4,
      buyer_pickup_start: "6:05 AM",
      buyer_pickup_end: "10:12 AM"
    )
  end
  let(:wednesday_schedule_description) { "Wednesdays from 5:30 PM to 8:15 PM at 44 E. 8th St Holland, MI 49423. For Buyer pick up/delivery Thursdays from 6:05 AM to 10:12 AM." }

  let!(:deleted_schedule) { create(:delivery_schedule, market: market, day: 2, deleted_at: Time.current) }

  before do
    Unit.create! singular: "Pound",  plural: "Pounds"
    Unit.create! singular: "Bushel", plural: "Bushels"
    switch_to_subdomain(market.subdomain)
  end

  it "navigating to form as an org user", js: true do
    org.users << user

    sign_in_as(user)

    within "#admin-nav" do
      click_link "Products"
    end
    click_link "Add New Product"
    # ^ This will fail in a case where having no specific markets is not handled
    expect(page).to have_field("Product Name")
  end

  it "navigating to form as an admin user", js: true do
    user.update_attribute(:role, "admin")

    sign_in_as(user)

    within "#admin-nav" do
      click_link "Products"
    end
    click_link "Add New Product"

    expect(page).to have_field("Product Name")
  end

  describe "as a seller belonging to one organization" do
    before do
      org.users << user

      sign_in_as(user)
      visit "/admin/products/new"
    end

    it "defaults to simple inventory" do
      simple_inventory_checkbox = page.find_field("Use simple inventory management")
      inventory_quantity = page.find_field("Current inventory")

      expect(simple_inventory_checkbox).to be_checked
      expect(inventory_quantity.value).to eql("0")
    end

    it "defaults to using all delivery schedules" do
      expect(find_field("Make product available on all market delivery dates")).to be_checked
    end

    context "filling in who/where/how", js: true do
      let(:product_form) { Dom::Admin::ProductForm.first }

      it "pre-populates the fields from the organization" do
        uncheck "seller_info"

        expect(page).to have_content("Who")

        expect(product_form.who_story).to eq("We sell products")
        expect(product_form.how_story).to eq("We sell products very carefully")
        expect(product_form.selected_location).to eq(org.locations.default_shipping.to_param)
      end

      it "saves changes made to fields if checked and unchecked" do
        location2 = create(:location, name: "Good Place", organization: org)

        visit "/admin/products/new"

        uncheck "seller_info"
        expect(page.find(".seller_info_fields", visible: false)).to be_visible
        product_form = Dom::Admin::ProductForm.first

        fill_in "product_who_story", with: "We sell other stuff"
        fill_in "product_how_story", with: "By selling stuff"
        select "Good Place", from: "product_location_id"

        check "seller_info"
        expect(page.find(".seller_info_fields", visible: false)).to_not be_visible

        uncheck "seller_info"
        expect(page.find(".seller_info_fields", visible: false)).to be_visible

        expect(product_form.seller_info).to_not be_checked
        expect(product_form.who_story).to eq("We sell other stuff")
        expect(product_form.how_story).to eq("By selling stuff")
        expect(product_form.location.value.to_i).to eq(location2.id)
      end

      it "does not save the product who/where/how information if checked after updating who/how/where" do
        fill_in_required_fields(:with_chosen)

        uncheck "seller_info"
        expect(page.find(".seller_info_fields", visible: false)).to be_visible

        fill_in "product_who_story", with: "We sell other stuff"

        check "seller_info"
        expect(page.find(".seller_info_fields", visible: false)).to_not be_visible

        click_button "Save and Continue"

        click_link "Product Info"

        expect(page.find(".seller_info_fields", visible: false)).to_not be_visible

        product = Product.last.decorate

        expect(product.who_story).to eql(org.who_story)
        expect(product.how_story).to eql(org.how_story)
        expect(product.location).to eql(org.locations.default_shipping)
      end

      it "it uses a default address if using who/how" do
        fill_in "Product Name", with: "Good food"
        select_from_chosen "Grapes / Red Grapes", from: "Category"
        select_from_chosen "Pounds", from: "Unit"

        uncheck "seller_info"
        expect(page).to have_content("Who")

        fill_in "product_who_story", with: "We sell other stuff"
        click_button "Save and Continue"

        expect(page).not_to have_content("Location can't be blank")
        expect(product_form.selected_location).to eq(org.locations.default_shipping.to_param)
      end
    end

    it "attaching an image uploads an image when provided" do
      fill_in "Product Name", with: "Red Grapes"
      attach_file("Photo", "app/assets/images/backgrounds/lentils.jpg")
      click_button "Save and Continue"
      expect(page).to have_css("img[alt='Red Grapes']")
    end

    it "adding simple inventory for the first time creates a new lot for the product", js: true do
      fill_in_required_fields(:with_chosen)
      select_from_chosen "Pounds", from: "Unit"
      fill_in("Current inventory", with: 33)

      click_button "Save and Continue"
      expect(page).to have_content("Added Red Grapes")

      click_link "Product Info"

      expect(page).to have_checked_field("Use simple inventory management")
      expect(page.find_field("Current inventory").value).to eql("33")

      expect(page).to have_content("Uncheck this to use advanced inventory tracking with lot numbers and expiration dates.")
      expect(page).to have_content("Pounds")

      within(".tabs") do
        expect(page).to_not have_content("Inventory")
      end
    end

    it "adding a product with advanced inventory hides the simple inventory field", :js do
      expect(page).to have_content("Current inventory")

      uncheck "Use simple inventory management"

      expect(page).to_not have_content("Current inventory")
    end

    context "using the choose category typeahead", js: true do
      let(:category_select) { Dom::CategorySelect.first }

      it "can quickly drill down to a result" do
        category_select.click

        expect(category_select.visible_options).to have_text("Macintosh Apples")
        expect(category_select.visible_options).to have_text("Turnips")

        category_select.type_search("grapes")

        expect(category_select.visible_options).to have_text("Red Grapes")
        expect(category_select.visible_options).to have_text("Green Grapes")
        expect(category_select.visible_options).to_not have_text("Turnips")
        expect(category_select.visible_options).to_not have_text("Macintosh Apples")

        category_select.visible_option("Grapes / Red Grapes").click

        expect(page).to have_content("Fruits / Grapes / Red Grapes")

        # Set the product name so we have a valid product
        fill_in "Product Name", with: "Red Grapes"
        fill_in "Short description", with: "Apples are yummy!"
        select_from_chosen "Pound", from: "Unit"

        click_button "Save and Continue"
        expect(page).to have_content("Added Red Grapes")

        click_link "Product Info"

        expect(page).to have_content("Grapes / Red Grapes")
      end

      it "fuzzy searches across top-level categories" do
        category_select.click

        expect(category_select.visible_options).to have_text("Macintosh Apples")
        expect(category_select.visible_options).to have_text("Turnips")

        category_select.type_search("fruit apples mac")

        expect(category_select.visible_options).to_not have_text("Turnips")
        expect(category_select.visible_options).to have_text("Macintosh Apples")

        category_select.visible_option("Apples / Macintosh Apples").click

        expect(page).to have_content("Fruits / Apples / Macintosh Apples")
      end
    end

    context "when all input is valid", js: true do
      it "saves the product stub" do
        loc1 = create(:location, organization: org)
        loc2 = create(:location, organization: org)

        # We need to refresh to load the new locations
        visit "/admin/products/new"

        expect(page).to_not have_content(stub_warning_both)
        expect(page).to_not have_content(organization_label)

        fill_in_required_fields(:with_chosen)

        select_from_chosen "Bushels", from: "Unit"
        fill_in "Unit description", with: "48 lbs"
        fill_in "Long description", with: "There are many kinds of apples."

        fill_in "Current inventory", with: "12"
        uncheck "Use simple inventory management"

        uncheck :seller_info

        select loc1.name, from: "Where"

        fill_in "Who", with: "The farmers down the road."
        fill_in "How", with: "With water, earth, and time."

        click_button "Save and Continue"

        expect(page).to have_content("Added Red Grapes")

        expect(page).to have_content(stub_warning_both)

        expect(current_path).to eql(admin_product_lots_path(Product.last))

        lot_rows = Dom::LotRow.all
        expect(lot_rows.count).to eq(0)
      end

      it "selects all delivery schedules by default" do
        expect(page).to_not have_content(stub_warning_both)
        expect(page).to_not have_content(organization_label)

        fill_in_required_fields(:with_chosen)

        select_from_chosen "Bushels", from: "Unit"
        fill_in "Unit description", with: "48 lbs"
        fill_in "Long description", with: "There are many kinds of apples."

        fill_in "Current inventory", with: "12"

        click_button "Save and Continue"

        expect(page).to have_content("Added Red Grapes")

        click_link "Product Info"

        expect(Dom::Admin::ProductDelivery.count).to eql(3)
        [ ["Mondays", monday_schedule_description],
          ["Tuesdays", tuesday_schedule_description],
          ["Wednesdays", wednesday_schedule_description] ].each do |(day, expected_description)|
            del = Dom::Admin::ProductDelivery.find_by_weekday(day)
            expect(del).to be_checked, "#{day} should be checked"
            expect(del.description).to eq(expected_description), "#{day} wrong description, wanted '#{expected_description}' but got '#{del.description}'"
        end
      end

      it "allows the user to select delivery schedules" do
        expect(page).to_not have_content(stub_warning_both)
        expect(page).to_not have_content(organization_label)

        expect(page).to have_content(tuesday_schedule_description)

        fill_in_required_fields(:with_chosen)

        select_from_chosen "Bushels", from: "Unit"
        fill_in "Long description", with: "There are many kinds of apples."

        fill_in "Current inventory", with: "12"

        uncheck "Make product available on all market delivery dates"
        Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays").uncheck!

        click_button "Save and Continue"

        expect(page).to have_content("Added Red Grapes")

        click_link "Product Info"

        expect(Dom::Admin::ProductDelivery.count).to eql(3)
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Mondays")).to be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays")).to_not be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Wednesdays")).to be_checked
      end

      it "user can not deselect required deliveries" do
        expect(page).to_not have_content(stub_warning_both)
        expect(page).to_not have_content(organization_label)

        expect(page).to have_content(tuesday_schedule_description)

        fill_in_required_fields(:with_chosen)

        select_from_chosen "Bushels", from: "Unit"
        fill_in "Long description", with: "There are many kinds of apples."

        fill_in "Current inventory", with: "12"

        uncheck "Make product available on all market delivery dates"
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Mondays").node.find("input")).to be_disabled
      end
    end

    context "when the product information is invalid", js: true do
      it "does not create the product" do
        expect(page).to have_content("Current inventory")
        uncheck "Use simple inventory management"

        click_button "Save and Continue"
        expect(page).to have_content("Name can't be blank")
        expect(page).to have_content("Category can't be blank")
        expect(page).to_not have_content("Current inventory")
        expect(page).to have_checked_field("Use Seller info from my account.")

        within(".tabs") do
          expect(page).to have_content("Inventory")
        end
      end

      it "maintains delivery schedule changes on error" do
        uncheck "Make product available on all market delivery dates"
        Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays").uncheck!
        click_button "Save and Continue"

        expect(page).to have_unchecked_field("Make product available on all market delivery dates")
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Mondays")).to be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays")).to_not be_checked
      end
    end

    it "organization in multiple markets defaults to simple inventory" do
      org.markets << create(:market, :with_addresses)

      # Refresh to grab the new market
      visit "/admin/products/new"

      simple_inventory_checkbox = page.find_field("Use simple inventory management")
      inventory_quantity = page.find_field("Current inventory")

      expect(simple_inventory_checkbox).to be_checked
      expect(inventory_quantity.value).to eql("0")
    end
  end

  describe "a seller belonging to multiple organizations" do
    let!(:org2) { create(:organization, :single_location, markets: [market], who_story: "who org2", how_story: "how org2") }
    let!(:buying_org) { create(:organization, :buyer) }

    before do
      user.organizations << [org, org2]

      sign_in_as(user)
      visit "/admin/products/new"
    end

    it "is prevented from unchecking 'Use seller info from my account' until organization is selected", js: true do
      expect(page).not_to have_field("seller_info")

      select org2.name, from: "Seller Organization"

      expect(page).to have_field("seller_info")

      # Wait for delivery schedule request to finish
      expect(page).to have_checked_field(tuesday_schedule_description, disabled: true)
    end

    context "Uncheck 'use seller info'", js: true do
      before do
        select org2.name, from: "Seller Organization"
        uncheck "seller_info"

        # Wait for delivery schedule load to finish
        # Should help with timing issues
        expect(page).to have_checked_field(tuesday_schedule_description, disabled: true)
      end

      it "pre-populates who/where/how fields from the organization" do
        expect(page).to have_content("Who")

        product_form = Dom::Admin::ProductForm.first
        expect(product_form.who_story).to eq("who org2")
        expect(product_form.how_story).to eq("how org2")

        expect(product_form.locations).to include(*org2.locations.map(&:name))
        expect(product_form.locations).to_not include(*org.locations.map(&:name))
      end

      it "selecting a different organization repopulates the locations list" do
        select org2.locations.first.name, from: "product_location_id"
        expect(page).not_to have_content("No Organization Selected")
        expect(Dom::Admin::ProductForm.first.selected_location).to eql(org2.locations.first.id.to_s)
        select org.name, from: "Seller Organization"

        product_form = Dom::Admin::ProductForm.first
        expect(product_form.locations).to include(*org.locations.map(&:name))
        expect(product_form.locations).not_to include(*org2.locations.map(&:name))

        # Wait for delivery schedule load to finish
        expect(page).to have_checked_field(tuesday_schedule_description, disabled: true)
      end

      it "selecting the blank organization option disables seller info" do
        expect(page).to have_field("seller_info")

        select "Select an organization", from: "Seller Organization"

        expect(page).not_to have_field("seller_info")
      end
    end

    it "maintains delivery schedule changes on error", :js, :shaky do
      skip "shaky test"
      select org2.name, from: "Seller Organization"
      expect(page).to have_checked_field(tuesday_schedule_description, disabled: true)

      uncheck "Make product available on all market delivery dates"
      Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays").uncheck!

      click_button "Save and Continue"
      patiently(20) do
        expect(page).to have_unchecked_field("Make product available on all market delivery dates")
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Mondays")).to be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays")).to_not be_checked
      end
    end

    it "does not offer non-selling organizations as options for the Organization select" do
      product_form = Dom::Admin::ProductForm.first
      expect(product_form.organization_field).to_not have_content(buying_org.name)
      expect(product_form.organization_field).to_not have_content(inactive_seller.name)
    end

    it "makes the user choose an organization to add the product to" do
      expect(page).to_not have_content(stub_warning_both)

      select org2.name, from: "Seller Organization"
      fill_in_required_fields

      click_button "Save and Continue"

      expect(page).to have_content("Added Red Grapes")
      expect(page).to have_content(stub_warning_both)
      expect(Product.last.organization).to eql(org2)
    end

    it "does not create the product when no organization has been chosen" do
      fill_in "Product Name", with: "Macintosh Apples"
      select "Apples / Macintosh Apples", from: "Category"

      click_button "Save and Continue"
      expect(page).to have_content("Organization can't be blank")
    end

    it "does not save a product with invalid product info", js: true do
      select org2.name, from: "Seller Organization"
      expect(page).to have_content("Current inventory")
      uncheck "Use simple inventory management"
      expect(page).not_to have_content("Current inventory")

      click_button "Save and Continue"

      # Shows error messages
      expect(page).to have_content("Name can't be blank")
      expect(page).to have_content("Category can't be blank")

      # Maintains inventory selections
      expect(page).not_to have_content("Current inventory")
      expect(page).to have_unchecked_field("Use simple inventory management")
      within(".tabs") do
        expect(page).to have_content("Inventory")
      end
      # Maintains organization selection
      expect(page).to have_checked_field("Use Seller info from my account.")
      expect(page).not_to have_content("No Organization Selected")
    end
  end

  describe "as a market manager", js: true do
    let!(:user) { create(:user, managed_markets: [market]) }
    let!(:org2) { create(:organization, :seller, markets: [market]) }

    before do
      sign_in_as(user)
      visit "/admin/products/new"
    end

    it "makes the user choose an organization to add the product for", js: true do
      select org2.name, from: "Seller Organization"

      fill_in_required_fields(:with_chosen)

      fill_in "product_simple_inventory", with: "30"

      click_button "Save and Continue"

      expect(page).to have_content("Added Red Grapes")

      expect(page).to have_content(stub_warning_pricing)
      expect(Product.last.organization).to eql(org2)
    end

    it "alerts user that product will not appear in the Shop until price/inventory are added" do
      expect(page).to_not have_content(stub_warning_both)
      select org2.name, from: "Seller Organization"

      # Wait for delivery schedule load to finish
      expect(page).to have_checked_field(tuesday_schedule_description, disabled: true)

      fill_in_required_fields(:with_chosen)

      click_button "Save and Continue"

      fill_in "price_net_price", with: "3.00"
      fill_in "price_sale_price", with: "2.00"
      click_button "Add"
      expect(page).to have_content(stub_warning_inventory)
    end
  end

  describe "additional taxonomy requests" do
    before do
      org.users << user
      sign_in_as(user)

      visit "/admin/products/new"
    end

    it "a user can request a new inventory unit" do
      click_link "Request a New Unit"

      expect(ZendeskMailer).to receive(:request_unit).with(
        user,
        "singular"         => "fathom",
        "plural"           => "fathoms",
        "additional_notes" => "See more notes"
      ).and_return(double(:mailer, deliver: true))

      fill_in "Singular", with: "fathom"
      fill_in "Plural", with: "fathoms"
      fill_in "Additional Notes", with: "See more notes"
      click_button "Request Unit"

      expect(page).to have_content("Add Product")
    end

    it "a user can request a new category" do
      click_link "Request a New Category"

      expect(ZendeskMailer).to receive(:request_category).with(
        user,
        "Goop"
      ).and_return(double(:mailer, deliver: true))

      fill_in "Product Category", with: "Goop"
      click_button "Request Category"

      expect(page).to have_content("Add Product")
    end
  end
end
