require "spec_helper"

describe "Editing a product", :js do
  let!(:seller) { create(:organization, :seller)}
  let!(:market)  { create(:market, :with_addresses, organizations: [seller]) }
  let!(:user) { create(:user, :supplier) }
  let!(:stub_warning) { "Your product will not appear in the Shop until all of these actions are complete" }
  let!(:organization_label) { "Product Organization" }
  let!(:product) { create(:product, organization: seller, name: "Canned Pears") }
  let!(:category_id) { product.category.id }

  before do
    switch_to_subdomain(market.subdomain)
  end

  describe "as a seller belonging to one organization" do
    let!(:seller) { create(:organization, :seller)}
    let!(:market)  { create(:market, :with_delivery_schedule, :with_addresses, organizations: [seller]) }
    let!(:user) { create(:user, :supplier) }
    let!(:stub_warning) { "Your product will not appear in the Shop until all of these actions are complete" }
    let!(:organization_label) { "Product Organization" }
    let!(:product) { create(:product, organization: seller, name: "Canned Pears") }
    let!(:category_id) { product.category.id }

    before do
      seller.users << user
      sign_in_as(user)
      #within "#admin-nav" do
        click_link "Products"
      #end
      click_link "Canned Pears"
    end

    context "when the product information is valid" do
      it "saves the product and advances to the inventory page" do
        fill_in "Product Name", with: "Canned Peaches"
        click_button "Save and Continue"
        expect(page).to have_content("Saved Canned Peaches")
        expect(page).to have_content("Add Inventory")
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
  end

  describe "additional taxonomy requests" do
    let!(:seller) { create(:organization, :seller)}
    let!(:market)  { create(:market, :with_delivery_schedule, :with_addresses, organizations: [seller]) }
    let!(:user) { create(:user, :supplier) }
    let!(:stub_warning) { "Your product will not appear in the Shop until all of these actions are complete" }
    let!(:organization_label) { "Product Organization" }
    let!(:product) { create(:product, organization: seller, name: "Canned Pears") }
    let!(:category_id) { product.category.id }

    before do
      product.organization.users << user
      sign_in_as(user)

      within "#admin-nav" do

        click_link "Products"
      end
      click_link "Canned Pears"
    end
  end

  describe "delivery schedules", js: true do
    let!(:monday_delivery) { create(:delivery_schedule, market: market, day: 1) }
    let!(:tuesday_delivery) { create(:delivery_schedule, :buyer_pickup, market: market, day: 2) }
    let!(:thursday_delivery) { create(:delivery_schedule, :buyer_pickup, market: market, day: 4, require_delivery: true) }

    context "single market membership" do
      before do
        product.organization.users << user
        product.delivery_schedule_ids = [monday_delivery.id]
        product.update(use_all_deliveries: false)

        sign_in_as(user)
        #within "#admin-nav" do
          click_link "Products"
        #end
        click_link "Canned Pears"
      end

      it "displays the market delivery options for the product" do
        expect(page).to have_content("Delivery Times")

        product_deliveries = Dom::Admin::ProductDelivery.all
        expect(product_deliveries.count).to eql(3)
        expect(find_field("Make product available on all market delivery dates")).to_not be_checked

        see_product_delivery_choices({delivery_schedule: monday_delivery, checked: true},
                                     {delivery_schedule: tuesday_delivery, checked: false},
                                     {delivery_schedule: thursday_delivery, checked: true, required: true})
      end

      it "persists changes" do
        uncheck "Make product available on all market delivery dates"

        Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Monday").uncheck!
        Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Tuesday").check!

        click_button "Save and Continue"
        click_link "Product Info"

        see_product_delivery_choices({delivery_schedule: monday_delivery, checked: false},
                                    {delivery_schedule: tuesday_delivery, checked: true})
      end

      it "allows all delivery schedules to be unselected" do
        uncheck "Make product available on all market delivery dates"

        Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Monday").uncheck!
        Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Tuesday").uncheck!

        click_button "Save and Continue"
        click_link "Product Info"

        expect(Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Monday")).to_not be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Tuesday")).to_not be_checked
      end

      it "does not allow required delivery to be unselected" do
        uncheck "Make product available on all market delivery dates"

        expect(Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Thursday").node.find("input")).to be_disabled
      end
    end

    context "multi-market membership" do
      let!(:second_market) { create(:market, :with_addresses, organizations: [product.organization]) }
      let!(:wednesday_delivery) { create(:delivery_schedule, market: second_market, day: 3) }

      before do
        product.organization.users << user
        product.delivery_schedule_ids = [monday_delivery.id]
        product.update(use_all_deliveries: false)

        sign_in_as(user)
        within "#admin-nav" do

          click_link "Products"
        end
        click_link "Canned Pears"
      end

      it "displays the market delivery options for the product" do
        expect(page).to have_content("Delivery Times")

        product_deliveries = Dom::Admin::ProductDelivery.all
        expect(product_deliveries.count).to eql(4)
        expect(find_field("Make product available on all market delivery dates")).to_not be_checked
        see_product_delivery_choices({delivery_schedule: monday_delivery, checked: true},
                                     {delivery_schedule: tuesday_delivery, checked: false},
                                     {delivery_schedule: wednesday_delivery, checked: false},
                                     {delivery_schedule: thursday_delivery, checked: true, required: true})
      end

      it "persists changes" do
        uncheck "Make product available on all market delivery dates"

        Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Monday").uncheck!
        Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Tuesday").check!
        Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Wednesday").uncheck!

        click_button "Save and Continue"
        click_link "Product Info"

        expect(Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Monday")).to_not be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Tuesday")).to be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Wednesday")).to_not be_checked
      end

      it "allows all optional delivery schedules to be unselected" do
        uncheck "Make product available on all market delivery dates"

        Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Monday").uncheck!
        Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Tuesday").uncheck!
        Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Wednesday").uncheck!

        click_button "Save and Continue"
        click_link "Product Info"

        expect(Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Monday")).to_not be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Tuesday")).to_not be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Wednesday")).to_not be_checked
      end

      it "saves state when there is an error" do
        uncheck "Make product available on all market delivery dates"

        Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Monday").uncheck!
        Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Tuesday").check!
        Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Wednesday").uncheck!

        fill_in "Name", with: ""

        click_button "Save and Continue"

        expect(page).to have_content("Name can't be blank")
        expect(find_field("Make product available on all market delivery dates")).to_not be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Monday")).to_not be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Tuesday")).to be_checked
        expect(Dom::Admin::ProductDelivery.find_by_weekday("Weekly, Wednesday")).to_not be_checked
      end
    end
  end
end
