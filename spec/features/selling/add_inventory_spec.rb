require "spec_helper"

describe "Adding advanced inventory" do
  let(:user) { create(:user) }
  let(:product){ create(:product) }

  before do
    Timecop.freeze(Date.parse("February 24, 2014"))
    product.organization.users << user
    sign_in_as(user)
    click_link "Products"
    click_link product.name
    click_link "Set Inventory"
  end

  after do
    Timecop.return
  end

  it "adds the inventory lot to the table" do
    within("#new_lot") do
      fill_in "lot_number", with: "3"
      fill_in "lot_good_from", with: "Tue, 25 Feb 2014"
      fill_in "lot_expires_at", with: "Wed, 10 Dec 2014"
      fill_in "lot_quantity", with: "12"
      click_button "Save"
    end

    expect(page).to have_content("Successfully added a new lot")

    lot_row = Dom::LotRow.first
    expect(lot_row).to_not be_nil
    expect(lot_row.number).to eql("3")
    expect(lot_row.good_from).to eql("02/25/2014")
    expect(lot_row.expires_at).to eql("12/10/2014")
    expect(lot_row.quantity).to eql("12")
  end

  it "shows an error when adding incomplete information" do
    within("#new_lot") do
      fill_in "lot_number", with: ""
      fill_in "lot_quantity", with: ""
      click_button "Save"
    end

    expect(page).to have_content("Could not save lot")
    expect(page).to have_content("Quantity can't be blank")

    expect(Dom::LotRow.first).to be_nil
  end

  it "shows an error when adding an expired lot" do
    within("#new_lot") do
      fill_in "lot_number", with: "3"
      fill_in "lot_good_from", with: "Tue, 25 Feb 2014"
      fill_in "lot_expires_at", with: "Wed, 10 Dec 2012"
      fill_in "lot_quantity", with: "12"
      click_button "Save"
    end

    expect(page).to have_content("Expires at must be in the future")
  end

  it "shows an error when the good from date is beyond the expires on date" do
    within("#new_lot") do
      fill_in "lot_number", with: "3"
      fill_in "lot_good_from", with: "Tue, 25 Feb 2015"
      fill_in "lot_expires_at", with: "Tue, 25 Dec 2012"
      fill_in "lot_quantity", with: "12"
      click_button "Save"
    end

    expect(page).to have_content("Good from cannot be after 'expires at'")
  end

  it "user can navigate back to product from the inventory page" do
    click_link "Product Info"
    product_form = Dom::ProductForm.first

    expect(product_form.organization_field.value).to eql(product.organization_id.to_s)
    expect(product_form.name.value).to eql(product.name.to_s)
    expect(product_form.category.value).to eql(product.category.id.to_s)
  end
end
