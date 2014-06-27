require "spec_helper"

describe "Editing a product" do
  let(:user) { create(:user) }
  let(:stub_warning) {"Your product will not appear in the Shop until all of these actions are complete"}
  let(:organization_label) { "Product Organization" }
  let(:product) { create(:product, name: "Canned Pears") }
  let!(:category_id) { product.category.id }
  let(:market)  { create(:market, :with_addresses, organizations: [product.organization]) }

  before do
    switch_to_subdomain(market.subdomain)
  end

  describe "as a seller belonging to one organization" do
    before do
      product.organization.users << user
      sign_in_as(user)
      within '#admin-nav' do
        click_link 'Products'
      end
      click_link "Canned Pears"
    end

    context "when the product information is valid", :js do
      it "saves the product and advances to the prices page" do
        fill_in "Product Name", with: "Canned Peaches"
        click_button "Save and Continue"
        expect(page).to have_content("Saved Canned Peaches")
        expect(page).to have_content("Add Prices")
      end

      it "saves the product and goes back to the products list" do
        fill_in "Product Name", with: "Canned Peaches"
        fill_in "Unit description", with: "32 lbs"
        click_link "Save & Go to the Product List"

        expect(page).to have_content("Saved Canned Peaches")
        expect(page).to have_content("32 lbs")

        click_link "Canned Peaches"

        expect(page).to have_content("Update Canned Peaches")
      end
    end

    context "when the product information is not valid" do
      it "shows an error" do
        fill_in "Product Name", with: ""
        click_button "Save and Continue"

        expect(page).to have_content("Name can't be blank")
      end
    end

    context "and switching to simple inventory management", :js do
      let(:product) { create(:product, name: "Canned Pears", use_simple_inventory: false) }

      context "with available inventory" do
        before do
          product.lots.create!(quantity: 42)
          visit admin_product_path(product)
        end

        it "user sees a warning message" do
          expect(page).to have_content("To use simple inventory management you must clear out your current available inventory")
        end

        it "user can't check simple inventory" do
          expect(page).to have_css("#product_use_simple_inventory[disabled]")
        end
      end

      context "with no available inventory", js: true do
        it "user can select simple inventory and set a simple inventory value" do
          expect(page).to_not have_content("Current inventory")

          check 'Use simple inventory'
          fill_in 'Current inventory', with: '42'
          click_button 'Save and Continue'

          expect(page).to have_content("Saved Canned Pears")
          expect(page).to have_content("Your product will not appear in the Shop until you add pricing")
        end
      end
    end
  end

  describe "additional taxonomy requests" do
    before do
      product.organization.users << user
      sign_in_as(user)

      within '#admin-nav' do
        click_link 'Products'
      end
      click_link "Canned Pears"
    end

    describe "a user can request a new inventory unit" do
      it "allows the user to request a new unit" do
        click_link "Request a New Unit"

        expect(ZendeskMailer).to receive(:request_unit).with(user.email, user.name, {
          "singular" => "fathom",
          "plural" => "fathoms",
          "additional_notes" => "See more notes"
        }).and_return(double(:mailer, deliver: true))

        fill_in "Singular", with: "fathom"
        fill_in "Plural", with: "fathoms"
        fill_in "Additional Notes", with: "See more notes"
        click_button "Request Unit"

        expect(page).to have_content("Add Product")
      end

      it "does not refresh the page", js: true do
        fill_in "Product Name", with: "Canned Peaches"
        click_link "Request a New Unit"

        expect(ZendeskMailer).to receive(:request_unit).and_return(double(:mailer, deliver: true))

        fill_in "Singular", with: "fathom"
        fill_in "Plural", with: "fathoms"
        fill_in "Additional Notes", with: "See more notes"
        click_button "Request Unit"

        expect(page).to have_field("Product Name", with: "Canned Peaches")
        expect(page).not_to have_field("Singular")
      end
    end

    describe "a user can request a new category" do
      it "allows the user to request a new category" do
        click_link "Request a New Category"

        expect(ZendeskMailer).to receive(:request_category).with(
          user.email, user.name, "Goop"
        ).and_return(double(:mailer, deliver: true))

        fill_in "Product Category", with: "Goop"
        click_button "Request Category"

        expect(page).to have_content("Add Product")
      end

      it "does not refresh the page", js: true do
        fill_in "Product Name", with: "Canned Peaches"
        click_link "Request a New Category"

        expect(ZendeskMailer).to receive(:request_category).and_return(double(:mailer, deliver: true))

        fill_in "Product Category", with: "Goop"
        click_button "Request Category"

        expect(page).to have_field("Product Name", with: "Canned Peaches")
        expect(page).not_to have_field("Product Category")
      end
    end
  end

  describe "delivery schedules", js: true do
    let!(:monday_delivery) { create(:delivery_schedule, market: market, day: 1) }
    let!(:tuesday_delivery) { create(:delivery_schedule, :buyer_pickup, market: market, day: 2) }
    let!(:thursday_delivery) { create(:delivery_schedule, :buyer_pickup, market: market, day: 4, require_delivery: true) }

    context 'single market membership' do
      before do
        product.organization.users << user
        product.delivery_schedule_ids = [monday_delivery.id]
        product.update(use_all_deliveries: false)

        sign_in_as(user)
        within '#admin-nav' do
          click_link 'Products'
        end
        click_link "Canned Pears"
      end

      it "displays the market delivery options for the product" do
        expect(page).to have_content("Delivery Times")

        product_deliveries = Dom::Admin::ProductDelivery.all
        expect(product_deliveries.count).to eql(3)
        expect(find_field("Make product available on all market delivery dates")).to_not be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Mondays")).to be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays")).to_not be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Thursdays")).to be_checked

        expect(page).to have_content("Mondays from 7:00 AM to 11:00 AM direct to customer")
        expect(page).to have_content("Tuesdays from 10:00 AM to 12:00 PM at 44 E. 8th St Holland, MI 49423")
        expect(page).to have_content("Thursdays from 10:00 AM to 12:00 PM at 44 E. 8th St Holland, MI 49423")
      end

      it "persists changes" do
        uncheck "Make product available on all market delivery dates"

        Dom::Admin::ProductDelivery.find_by_weekday("Mondays").uncheck!
        Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays").check!

        click_button "Save and Continue"
        click_link "Product Info"

        expect(Dom::Admin::ProductDelivery.find_by_weekday("Mondays")).to_not be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays")).to be_checked
      end

      it "allows all delivery schedules to be unselected" do
        uncheck "Make product available on all market delivery dates"

        Dom::Admin::ProductDelivery.find_by_weekday("Mondays").uncheck!
        Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays").uncheck!

        click_button "Save and Continue"
        click_link "Product Info"

        expect(Dom::Admin::ProductDelivery.find_by_weekday("Mondays")).to_not be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays")).to_not be_checked
      end

      it "does not allow required delivery to be unselected" do
        uncheck "Make product available on all market delivery dates"

        expect(Dom::Admin::ProductDelivery.find_by_weekday("Thursdays").node.find('input')).to be_disabled
      end
    end

    context 'multi-market membership' do
      let!(:second_market) { create(:market, :with_addresses, organizations: [product.organization]) }
      let!(:wednesday_delivery) { create(:delivery_schedule, market: second_market, day: 3) }

      before do
        product.organization.users << user
        product.delivery_schedule_ids = [monday_delivery.id]
        product.update(use_all_deliveries: false)

        sign_in_as(user)
        within '#admin-nav' do
          click_link 'Products'
        end
        click_link "Canned Pears"
      end

      it "displays the market delivery options for the product" do
        expect(page).to have_content("Delivery Times")

        product_deliveries = Dom::Admin::ProductDelivery.all
        expect(product_deliveries.count).to eql(4)
        expect(find_field("Make product available on all market delivery dates")).to_not be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Mondays")).to be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays")).to_not be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Wednesdays")).to_not be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Thursdays")).to be_checked

        expect(page).to have_content("Mondays from 7:00 AM to 11:00 AM direct to customer")
        expect(page).to have_content("Tuesdays from 10:00 AM to 12:00 PM at 44 E. 8th St Holland, MI 49423")
        expect(page).to have_content("Wednesdays from 7:00 AM to 11:00 AM direct to customer")
        expect(page).to have_content("Thursdays from 10:00 AM to 12:00 PM at 44 E. 8th St Holland, MI 49423")
      end

      it "persists changes" do
        uncheck "Make product available on all market delivery dates"

        Dom::Admin::ProductDelivery.find_by_weekday("Mondays").uncheck!
        Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays").check!
        Dom::Admin::ProductDelivery.find_by_weekday("Wednesdays").uncheck!

        click_button "Save and Continue"
        click_link "Product Info"

        expect(Dom::Admin::ProductDelivery.find_by_weekday("Mondays")).to_not be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays")).to be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Wednesdays")).to_not be_checked
      end

      it "allows all optional delivery schedules to be unselected" do
        uncheck "Make product available on all market delivery dates"

        Dom::Admin::ProductDelivery.find_by_weekday("Mondays").uncheck!
        Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays").uncheck!
        Dom::Admin::ProductDelivery.find_by_weekday("Wednesdays").uncheck!

        click_button "Save and Continue"
        click_link "Product Info"

        expect(Dom::Admin::ProductDelivery.find_by_weekday("Mondays")).to_not be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays")).to_not be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Wednesdays")).to_not be_checked
      end

      it "saves state when there is an error" do
        uncheck "Make product available on all market delivery dates"

        Dom::Admin::ProductDelivery.find_by_weekday("Mondays").uncheck!
        Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays").check!
        Dom::Admin::ProductDelivery.find_by_weekday("Wednesdays").uncheck!

        fill_in "Name", with: ""

        click_button "Save and Continue"

        expect(page).to have_content("Name can't be blank")
        expect(find_field("Make product available on all market delivery dates")).to_not be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Mondays")).to_not be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays")).to be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Wednesdays")).to_not be_checked
      end
    end
  end
end
