require 'spec_helper'

describe "Manage Discount Codes" do
  let!(:market)              { create(:market) }
  let!(:discount_fixed)      { create(:discount, name: "fixed discount", type: "fixed", discount: 5.00) }
  let!(:discount_percentage) { create(:discount, name: "percentage discount", type: "percentage", discount: 0.10) }
  let!(:user)                { create(:user, :admin) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  it "can be accessed via the menu" do
    within '#admin-nav' do
      click_link 'Marketing'
    end
    click_link "Discount Codes"

    expect(page).to have_content("Add New Discount")
  end

  it "shows a list of discount codes" do
    visit admin_discounts_path

    expect(Dom::Admin::DiscountRow.all.count).to eql(2)

    code = Dom::Admin::DiscountRow.find_by_name(discount_fixed.name)
    expect(code.code).to have_content(discount_fixed.code)

    code = Dom::Admin::DiscountRow.find_by_name(discount_percentage.name)
    expect(code.code).to have_content(discount_percentage.code)
  end

  context "Creation" do

  end

  context "Deletion" do

  end

  context "Updation" do

  end
end
