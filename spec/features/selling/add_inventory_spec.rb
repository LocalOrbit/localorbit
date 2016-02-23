require "spec_helper"

describe "Adding advanced inventory" do
  let(:user) { create(:user, :market_manager) }
  let(:product) { create(:product, use_simple_inventory: false) }

  let(:empty_inventory_message) { "You don't have any Inventory" }
  let(:market)  { create(:market, organizations: [product.organization]) }

  let(:new_lot_form_id) { "#p#{product.id}_new_lot" }

  before do
    switch_to_subdomain(market.subdomain)
  end

=begin
  context "without js" do
    before do
      Timecop.freeze(Date.parse("February 24, 2014"))
      product.organization.users << user
      sign_in_as(user)
      within "#admin-nav" do
        click_link "Products"
      end
      click_link product.name
      click_link "Inventory"
    end

    after do
      Timecop.return
    end

    it "adds the inventory lot to the table" do
      expect(page).to have_content(empty_inventory_message)

      within(new_lot_form_id) do
        fill_in "lot[number]", with: "3"
        fill_in "lot[good_from]", with: "Tue, 25 Feb 2014"
        fill_in "lot[expires_at]", with: "Wed, 10 Dec 2014"
        fill_in "lot[quantity]", with: "12"
        click_button "Add"
      end

      expect(page).to have_content("Successfully added a new lot")
      expect(page).to_not have_content(empty_inventory_message)

      lot_row = Dom::LotRow.first
      expect(lot_row).to_not be_nil
      expect(lot_row.number).to eql("3")
      expect(lot_row.good_from).to eql("25 Feb 2014")
      expect(lot_row.expires_at).to eql("10 Dec 2014")
      expect(lot_row.quantity).to eql("12")
      expect(".add-row.is-hidden").to be
    end

    it "shows an error when adding incomplete information" do
      within(new_lot_form_id) do
        fill_in "lot[number]", with: ""
        fill_in "lot[quantity]", with: ""
        click_button "Add"
      end

      expect(page).to have_content("Could not save lot")
      expect(page).to have_content("Quantity is not a number")

      expect(Dom::LotRow.all.map { |r| r.node[:class] }).to eq(["lot add-row editing"])
    end

    it "shows an error when adding an expired lot" do
      within(new_lot_form_id) do
        fill_in "lot[number]", with: "3"
        fill_in "lot[good_from]", with: "Tue, 25 Feb 2014"
        fill_in "lot[expires_at]", with: "Wed, 10 Dec 2012"
        fill_in "lot[quantity]", with: "12"
        click_button "Add"
      end

      expect(page).to have_content("Expires On must be in the future")
    end

    it "shows an error when the good from date is beyond the expires on date" do
      #save_and_open_page
      within(new_lot_form_id) do
        fill_in "lot[number]", with: "3"
        fill_in "lot[good_from]", with: "Tue, 25 Feb 2015"
        fill_in "lot[expires_at]", with: "Tue, 25 Dec 2012"
        fill_in "lot[quantity]", with: "12"
        click_button "Add"
      end

      expect(page).to have_content("Good From cannot be after expires at date")
    end

    it "user can navigate back to product from the inventory page" do
      click_link "Product Info"
      product_form = Dom::Admin::ProductForm.first
      expect(product_form).to have_link(product.organization.name)

      expect(product_form.name.value).to eql(product.name.to_s)
      expect(product_form.category.value).to eql(product.category.id.to_s)
    end
  end
=end

  context "with js", js: true do
    before do
      product.organization.users << user
      sign_in_as(user)
      within "#admin-nav" do

        click_link "Products"
      end
      click_link product.name
      click_link "Inventory"
      find(:css, ".adv_inventory").click
    end

    it "populates the correct date on validation errors" do
      expected_date = 1.month.from_now.change(day: 15).strftime("%d %b %Y")
      datepicker = Dom::InlineDatePicker.open("lot[expires_at]")
      datepicker.click_next
      datepicker.click_day("15")

      expect(find_field("lot[expires_at]").value).to eq(expected_date)

      click_button "Add"

      expect(page).to have_content("Lot # can't be blank when 'Expiration Date' is present")
      expect(find_field("lot[expires_at]").value).to eq(expected_date)
    end
  end
end
