require "spec_helper"

describe "Adding advanced inventory" do
  let!(:seller) { create(:organization, :seller)}
  let!(:market)  { create(:market, :with_delivery_schedule, organizations: [seller]) }
  let!(:product) { create(:product, organization: seller, use_simple_inventory: false) }

  let!(:empty_inventory_message) { "You don't have any Inventory" }

  let!(:new_lot_form_id) { "#p#{product.id}_new_lot" }
  let!(:user) { create(:user, :supplier, organizations: [seller]) }

  before do
    switch_to_subdomain(market.subdomain)
  end

  context "with js", js: true do
    before do
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
