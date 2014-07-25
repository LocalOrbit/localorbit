require 'spec_helper'

describe "Manage Discount Codes" do
  let!(:market)              { create(:market) }
  let!(:discount_fixed)      { create(:discount, name: "fixed discount", type: "fixed", discount: 5.00) }
  let!(:discount_percentage) { create(:discount, name: "percentage discount", type: "percentage", discount: 10) }
  let(:organization)         { create(:organization, :buyer, markets: [market]) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  context "organization users" do
    let!(:user) { create(:user, organizations: [organization]) }

    it "gives a 404 page" do
      visit admin_discounts_path
      expect(page.status_code).to eql(404)
    end
  end

  context "market managers" do
    let!(:user) { create(:user, managed_markets: [market]) }

    it "can be accessed via the menu" do
      within '#admin-nav' do
        click_link 'Marketing'
      end
      click_link "Discount Codes"

      expect(page).to have_content("Add New Discount")
    end

    it "does not show 'All Markets' as an option" do
      
    end

    it "shows a list of discount codes" do
      visit admin_discounts_path

      expect(Dom::Admin::DiscountRow.all.count).to eql(2)

      code = Dom::Admin::DiscountRow.find_by_name(discount_fixed.name)
      expect(code).to_not be_nil
      expect(code.code).to have_content(discount_fixed.code)
      expect(code.type).to have_content("$")
      expect(code.amount).to have_content("$5.00")

      code = Dom::Admin::DiscountRow.find_by_name(discount_percentage.name)
      expect(code).to_not be_nil
      expect(code.code).to have_content(discount_percentage.code)
      expect(code.type).to have_content("%")
      expect(code.amount).to have_content("10.0%")
    end

    context "Creation" do
      it 'adds a new discount code' do
        visit new_admin_discount_path

        fill_in "Name", with: "Anniversary Celebration"
        fill_in "Code", with: "CELEBRATE3"
        select "Percentage", from: "Type"
        fill_in "Discount", with: "30"

        click_button "Save Discount"

        expect(page).to have_content("Successfully created discount")
        expect(Dom::Admin::DiscountRow.all.count).to eql(3)
        expect(Dom::Admin::DiscountRow.find_by_name("Anniversary Celebration")).to_not be_nil
      end

      it 'displays error messages when the code is invalid' do
        visit new_admin_discount_path

        click_button "Save Discount"

        expect(page).to have_content("Error creating discount")
      end
    end

    context "Deletion" do
      it "removes the discount code" do
        visit admin_discounts_path

        expect(Dom::Admin::DiscountRow.all.count).to eql(2)

        code = Dom::Admin::DiscountRow.find_by_name(discount_fixed.name)
        code.click_delete

        expect(page).to have_content("Successfully removed discount")
        expect(Dom::Admin::DiscountRow.all.count).to eql(1)

        expect(Dom::Admin::DiscountRow.find_by_name(discount_fixed.name)).to be_nil
      end
    end

    context "Updation" do
      it 'updates an existing discount code' do
        visit admin_discount_path(discount_fixed)

        fill_in "Name", with: "Black Friday"

        click_button "Save Discount"

        expect(page).to have_content("Successfully updated discount")
        expect(Dom::Admin::DiscountRow.all.count).to eql(2)
        expect(Dom::Admin::DiscountRow.find_by_name("Black Friday")).to_not be_nil
      end

      it 'displays error messages when the code is invalid' do
        visit admin_discount_path(discount_fixed)

        fill_in "Name", with: ""

        click_button "Save Discount"

        expect(page).to have_content("Error updating discount")
      end
    end
  end

  context "admins" do
    let!(:user) { create(:user, :admin) }

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
      expect(code).to_not be_nil
      expect(code.code).to have_content(discount_fixed.code)
      expect(code.type).to have_content("$")
      expect(code.amount).to have_content("$5.00")

      code = Dom::Admin::DiscountRow.find_by_name(discount_percentage.name)
      expect(code).to_not be_nil
      expect(code.code).to have_content(discount_percentage.code)
      expect(code.type).to have_content("%")
      expect(code.amount).to have_content("10.0%")
    end

    context "Creation" do
      it 'adds a new discount code' do
        visit new_admin_discount_path

        fill_in "Name", with: "Anniversary Celebration"
        fill_in "Code", with: "CELEBRATE3"
        select "Percentage", from: "Type"
        fill_in "Discount", with: "30"

        click_button "Save Discount"

        expect(page).to have_content("Successfully created discount")
        expect(Dom::Admin::DiscountRow.all.count).to eql(3)
        expect(Dom::Admin::DiscountRow.find_by_name("Anniversary Celebration")).to_not be_nil
      end

      it 'displays error messages when the code is invalid' do
        visit new_admin_discount_path

        click_button "Save Discount"

        expect(page).to have_content("Error creating discount")
      end
    end

    context "Deletion" do
      it "removes the discount code" do
        visit admin_discounts_path

        expect(Dom::Admin::DiscountRow.all.count).to eql(2)

        code = Dom::Admin::DiscountRow.find_by_name(discount_fixed.name)
        code.click_delete

        expect(page).to have_content("Successfully removed discount")
        expect(Dom::Admin::DiscountRow.all.count).to eql(1)

        expect(Dom::Admin::DiscountRow.find_by_name(discount_fixed.name)).to be_nil
      end
    end

    context "Updation" do
      it 'updates an existing discount code' do
        visit admin_discount_path(discount_fixed)

        fill_in "Name", with: "Black Friday"

        click_button "Save Discount"

        expect(page).to have_content("Successfully updated discount")
        expect(Dom::Admin::DiscountRow.all.count).to eql(2)
        expect(Dom::Admin::DiscountRow.find_by_name("Black Friday")).to_not be_nil
      end

      it 'displays error messages when the code is invalid' do
        visit admin_discount_path(discount_fixed)

        fill_in "Name", with: ""

        click_button "Save Discount"

        expect(page).to have_content("Error updating discount")
      end
    end
  end
end
