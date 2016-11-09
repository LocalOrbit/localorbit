require "spec_helper"

describe "Adding a product", chosen_js: true do
  def fill_in_required_fields(select=:without_chosen)
    fill_in "Product Name", with: "Red Grapes"
    fill_in "Short description", with: "Grapes are yummy!"

    case select
    when :without_chosen
      select "Apples", from: "Category"
      select "Pound", from: "Unit"
    when :with_chosen
      select_from_chosen "Grapes", from: "Category"
      select_from_chosen "Pound", from: "Unit"
    end
  end

  let!(:aggregation_point)     { create(:market_address, market: market, name: "Aggregation Point", address: "1123 Grand Rd.", city: "Appleton", state: "WI", zip: "83992") }
  let!(:org)                   { create(:organization, :seller, :single_location, who_story: "We sell products", how_story: "We sell products very carefully") }
  let(:stub_warning_pricing)   { "will not appear in the shop until you add Pricing" }
  let(:stub_warning_inventory) { "will not appear in the shop until you add Inventory" }
  let(:stub_warning_both)      { "will not appear in the shop until you add Inventory and add Pricing" }
  let(:organization_label)     { "Product Organization" }
  let!(:user)                  { create(:user, :supplier, organizations: [org]) }
  let!(:market)                { create(:market, :with_addresses, organizations: [org]) }

  let!(:inactive_seller) { create(:organization, :seller, active: false) }

  let!(:mondays_schedule) { create(:delivery_schedule, market: market, day: 1, require_delivery: true) }
  let(:monday_schedule_description) { "Weekly, Monday from 7:00 AM to 11:00 AM direct to customer. (required)" }
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
  let(:tuesday_schedule_description) { "Weekly, Tuesday from 7:00 AM to 9:00 AM at 1123 Grand Rd. Appleton, WI 83992. For Buyer pick up/delivery Tuesdays from 8:30 AM to 10:00 AM." }

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
  let(:wednesday_schedule_description) { "Weekly, Wednesday from 5:30 PM to 8:15 PM at 44 E. 8th St Holland, MI 49423. For Buyer pick up/delivery Thursdays from 6:05 AM to 10:12 AM." }

  let!(:deleted_schedule) { create(:delivery_schedule, market: market, day: 2, deleted_at: Time.current) }

  before do
    Unit.create! singular: "Pound",  plural: "Pounds"
    Unit.create! singular: "Bushel", plural: "Bushels"
    switch_to_subdomain(market.subdomain)
  end

  it "navigating to form as an org user", js: true do
    org.users << user

    sign_in_as(user)

    #within "#admin-nav" do

      click_link "Products"
    #end
    click_link "Add New Product"
    # ^ This will fail in a case where having no specific markets is not handled
    expect(page).to have_field("Product Name")
  end

  it "navigating to form as an admin user", js: true do
    user.roles << create(:role, :admin)

    sign_in_as(user)

    #within "#admin-nav" do

      click_link "Products"
    #end
    click_link "Add New Product"

    expect(page).to have_field("Product Name")
  end

  describe "as a supplier belonging to one organization" do
    before do
      org.users << user

      sign_in_as(user)
      visit "/admin/products/new"
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
        select_from_chosen "Grapes", from: "Category"
        select_from_chosen "Pounds", from: "Unit"

        uncheck "seller_info"
        expect(page).to have_content("Who")

        fill_in "product_who_story", with: "We sell other stuff"
        click_button "Save and Continue"

        expect(page).not_to have_content("Location can't be blank")
        expect(product_form.selected_location).to eq(org.locations.default_shipping.to_param)
      end
    end

    xit "attaching an image uploads an image when provided" do
      fill_in "Product Name", with: "Red Grapes"
      attach_file("file", "app/assets/images/backgrounds/lentils.jpg")

      click_button "Save and Continue"
      expect(page).to have_css("img[alt='Red Grapes']")
    end

    context "using the choose category typeahead", js: true do
      let(:category_select) { Dom::CategorySelect.first }

      it "can quickly drill down to a result" do
        category_select.click

        expect(category_select.visible_options).to have_text("Apples")
        expect(category_select.visible_options).to have_text("Potatoes & Root Vegetables")

        category_select.type_search("grapes")

        expect(category_select.visible_options).to have_text("Grapes")
        expect(category_select.visible_options).to_not have_text("Potatoes & Root Vegetables")
        expect(category_select.visible_options).to_not have_text("Apples")

        category_select.visible_option("Grapes").click

        expect(page).to have_content("Fruits / Grapes")

        # Set the product name so we have a valid product
        fill_in "Product Name", with: "Red Grapes"
        fill_in "Short description", with: "Apples are yummy!"
        select_from_chosen "Pound", from: "Unit"

        click_button "Save and Continue"
        expect(page).to have_content("Added Red Grapes")

        click_link "Product Info"

        expect(page).to have_content("Fruits / Grapes")
      end

      it "fuzzy searches across top-level categories" do
        category_select.click

        expect(category_select.visible_options).to have_text("Apples")
        expect(category_select.visible_options).to have_text("Potatoes & Root Vegetables")

        category_select.type_search("fruit apples")

        expect(category_select.visible_options).to_not have_text("Potatoes & Root Vegetables")
        expect(category_select.visible_options).to have_text("Apples")

        category_select.visible_option("Apples").click

        expect(page).to have_content("Fruits / Apples")
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

        uncheck :seller_info

        select loc1.name, from: "Where"

        fill_in "Who", with: "The farmers down the road."
        fill_in "How", with: "With water, earth, and time."

        click_button "Save and Continue"

        expect(page).to have_content("Added Red Grapes")

        expect(page).to have_content(stub_warning_both)
        expect(page).to have_content("for Bushels of Red Grapes yet!")

        expect(current_path).to eql(admin_product_lots_path(Product.last))

        expect(Dom::LotRow.all_classes).to eq(["lot add-row editing"])
      end

      it "selects all delivery schedules by default" do
        expect(page).to_not have_content(stub_warning_both)
        expect(page).to_not have_content(organization_label)

        fill_in_required_fields(:with_chosen)

        select_from_chosen "Bushels", from: "Unit"
        fill_in "Unit description", with: "48 lbs"
        fill_in "Long description", with: "There are many kinds of apples."

        click_button "Save and Continue"

        expect(page).to have_content("Added Red Grapes")

        click_link "Product Info"

        expect(Dom::Admin::ProductDelivery.count).to eql(3)
        [ ["Weekly, Monday", monday_schedule_description],
          ["Weekly, Tuesday", tuesday_schedule_description],
          ["Weekly, Wednesday", wednesday_schedule_description] ].each do |(day, expected_description)|
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

        uncheck "Make product available on all market delivery dates"
        Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Tuesday").uncheck!

        click_button "Save and Continue"

        expect(page).to have_content("Added Red Grapes")

        click_link "Product Info"

        expect(Dom::Admin::ProductDelivery.count).to eql(3)
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Monday")).to be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Tuesday")).to_not be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Wednesday")).to be_checked
      end

      it "user can not deselect required deliveries" do
        expect(page).to_not have_content(stub_warning_both)
        expect(page).to_not have_content(organization_label)

        expect(page).to have_content(tuesday_schedule_description)

        fill_in_required_fields(:with_chosen)

        select_from_chosen "Bushels", from: "Unit"
        fill_in "Long description", with: "There are many kinds of apples."

        uncheck "Make product available on all market delivery dates"
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Monday").node.find("input")).to be_disabled
      end
    end

    context "when the product information is invalid", js: true do
      it "does not create the product" do
        click_button "Save and Continue"
        expect(page).to have_content("Name can't be blank")
        expect(page).to have_content("Category can't be blank")
        expect(page).to have_checked_field("Use Supplier info from my account.")

        within(".tabs") do
          expect(page).to have_content("Inventory")
        end
      end

      it "maintains delivery schedule changes on error" do
        uncheck "Make product available on all market delivery dates"
        Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Tuesday").uncheck!
        click_button "Save and Continue"

        expect(page).to have_unchecked_field("Make product available on all market delivery dates")
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Monday")).to be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Tuesday")).to_not be_checked
      end
    end
  end

  describe "a seller belonging to multiple organizations" do
    let!(:org2) { create(:organization, :seller, :single_location, markets: [market], who_story: "who org2", how_story: "how org2") }
    let!(:buying_org) { create(:organization, :buyer) }

    before do
      user.organizations << [org, org2]

      sign_in_as(user)
      visit "/admin/products/new"
    end

    it "is prevented from unchecking 'Use supplier info from my account' until organization is selected", js: true do
      expect(page).not_to have_field("seller_info")

      select org2.name, from: "Supplier Organization", visible: false

      expect(page).to have_field("seller_info")

      # Wait for delivery schedule request to finish
      expect(page).to have_checked_field(tuesday_schedule_description, disabled: true)
    end

    context "Uncheck 'use supplier info'", js: true do
      before do
        select org2.name, from: "Supplier Organization", visible: false
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
        select org.name, from: "Supplier Organization", visible: false

        product_form = Dom::Admin::ProductForm.first
        expect(product_form.locations).to include(*org.locations.map(&:name))
        expect(product_form.locations).not_to include(*org2.locations.map(&:name))

        # Wait for delivery schedule load to finish
        expect(page).to have_checked_field(tuesday_schedule_description, disabled: true)
      end

      it "selecting the blank organization option disables supplier info" do
        expect(page).to have_field("seller_info")

        select "Select an organization", from: "Supplier Organization", visible: false

        expect(page).not_to have_field("seller_info")
      end
    end

    it "maintains delivery schedule changes on error", :js, :shaky do
      skip "shaky test"
      select org2.name, from: "Supplier Organization", visible: false
      expect(page).to have_checked_field(tuesday_schedule_description, disabled: true)

      uncheck "Make product available on all market delivery dates"
      Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays").uncheck!

      click_button "Save and Continue"
      patiently(20) do
        expect(page).to have_unchecked_field("Make product available on all market delivery dates")
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Monday")).to be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Tuesday")).to_not be_checked
      end
    end

    it "does not offer non-selling organizations as options for the Organization select" do
      product_form = Dom::Admin::ProductForm.first
      expect(product_form.organization_field).to_not have_content(buying_org.name)
      expect(product_form.organization_field).to_not have_content(inactive_seller.name)
    end

    it "makes the user choose an organization to add the product to" do
      expect(page).to_not have_content(stub_warning_both)

      select org2.name, from: "Supplier Organization", visible: false
      fill_in_required_fields

      click_button "Save and Continue"

      expect(page).to have_content("Added Red Grapes")
      expect(page).to have_content(stub_warning_both)
      expect(Product.last.organization).to eql(org2)
    end

    it "does not create the product when no organization has been chosen" do
      fill_in "Product Name", with: "Macintosh Apples"
      select "Apples", from: "Category"

      click_button "Save and Continue"
      expect(page).to have_content("Organization can't be blank")
    end

    it "does not save a product with invalid product info", js: true do
      select org2.name, from: "Supplier Organization", visible: false
      uncheck 'seller_info'

      click_button "Save and Continue"

      # Shows error messages
      expect(page).to have_content("Name can't be blank")
      expect(page).to have_content("Category can't be blank")

      # Maintains organization selection
      expect(page).not_to have_checked_field("Use Supplier info from my account.")
      expect(page).not_to have_content("No Organization Selected")
    end
  end

  describe "as a market manager", js: true do
    let!(:user) { create(:user, :market_manager, managed_markets: [market]) }
    let!(:org2) { create(:organization, :seller, markets: [market]) }

    before do
      sign_in_as(user)
      visit "/admin/products/new"
    end

    it "makes the user choose an organization to add the product for" do
      select org2.name, from: "Supplier Organization", visible: false

      fill_in_required_fields(:with_chosen)

      click_button "Save and Continue"

      expect(page).to have_content("Added Red Grapes")

      expect(page).to have_content(stub_warning_both)
      expect(Product.last.organization).to eql(org2)
    end

    describe "alerts user that product will not appear in the Shop" do
      before do
        expect(page).to_not have_content(stub_warning_both)
        select org2.name, from: "Supplier Organization", visible: false

        # Wait for delivery schedule load to finish
        expect(page).to have_checked_field(tuesday_schedule_description, disabled: true)

        fill_in_required_fields(:with_chosen)

        click_button "Save and Continue"
      end

      it "until inventory are added" do
        expect(page).to have_content(stub_warning_both)

        click_link "Continue to Pricing"

        expect(page).to have_content(stub_warning_both)
        fill_in "price[net_price]", with: "3.00"
        fill_in "price[sale_price]", with: "2.00"
        click_button "Add"
        expect(page).to have_content(stub_warning_inventory)
      end

      it "until prices are added", :js do
        expect(page).to have_content(stub_warning_both)

        find(:css, ".adv_inventory").click

        fill_in "lot[quantity]", with: "42"
        click_button "Add"
        expect(page).to have_content(stub_warning_pricing)
      end
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
