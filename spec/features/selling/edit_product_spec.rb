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

    context "when the product information is valid" do
      it "saves the product" do
        fill_in "Product Name", with: "Canned Peaches"
        click_button "Save Product"
        expect(find_field('Product Name').value).to eq("Canned Peaches")
        expect(find_field('Category').value).to eq(category_id.to_s)
      end
    end

    context "when the product information is not valid" do
      it "shows an error" do
        fill_in "Product Name", with: ""
        click_button "Save Product"

        expect(page).to have_content("Name can't be blank")
      end
    end

    context "and switching to simple inventory management", js: true do
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
          click_button 'Save Product'

          expect(page).to have_content("Saved Canned Pears")
          expect(find_field("Current inventory").value).to eq('42')
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

  describe "delivery schedules" do
    let!(:monday_delivery) { create(:delivery_schedule, market: market, day: 1) }
    let!(:tuesday_delivery) { create(:delivery_schedule, :buyer_pickup, market: market, day: 2) }

    before do
      product.organization.users << user
      product.delivery_schedule_ids = [monday_delivery.id]
      sign_in_as(user)
      within '#admin-nav' do
        click_link 'Products'
      end
      click_link "Canned Pears"
    end

    it "displays the market delivery options for the product" do
      expect(page).to have_content("Delivery Times")

      product_deliveries = Dom::Admin::ProductDelivery.all
      expect(product_deliveries.count).to eql(2)
      expect(Dom::Admin::ProductDelivery.find_by_weekday("Mondays")).to be_checked
      expect(Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays")).to_not be_checked

      expect(page).to have_content("Mondays from 7:00 AM to 11:00 AM direct to customer")
      expect(page).to have_content("Tuesdays from 10:00 AM to 12:00 PM at Market Address")
    end

    it "persists changes" do
      mondays = Dom::Admin::ProductDelivery.find_by_weekday("Mondays")
      mondays.uncheck!
      tuesdays = Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays")
      tuesdays.check!

      click_button "Save Product"

      expect(Dom::Admin::ProductDelivery.find_by_weekday("Mondays")).to_not be_checked
      expect(Dom::Admin::ProductDelivery.find_by_weekday("Tuesdays")).to be_checked
    end
  end
end
