require "spec_helper"

describe "Manage Discount Codes" do
  let!(:startup_plan)        { create(:plan, :start_up, discount_codes: false) }
  let!(:grow_plan)           { create(:plan, :grow, discount_codes: true) }

  let(:supplier)             { create(:organization, :seller) }

  let!(:market_org1)         { create(:organization,:market, plan: grow_plan)}
  let!(:market)              { create(:market, organization: market_org1, organizations:[supplier]) }
  let!(:market_org2)         { create(:organization,:market, plan: startup_plan)}
  let!(:market2)             { create(:market, organization: market_org2) }
  let!(:market_org3)         { create(:organization,:market, plan: grow_plan)}
  let!(:market3)             { create(:market, organization: market_org3) }

  let!(:discount_fixed)      { create(:discount, market: market, name: "fixed discount", type: "fixed", discount: 5.00) }
  let!(:discount_percentage) { create(:discount, market: market, name: "percentage discount", type: "percentage", discount: 10, maximum_uses: 10) }
  let!(:discount_percentage2){ create(:discount, market: market3, name: "another percentage discount", type: "percentage", discount: 25, maximum_uses: 5) }

  let!(:order)               { create(:order, discount: discount_percentage) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  context "organization users" do
    let!(:user) { create(:user, :supplier) }

    it "gives a 404 page" do
      visit admin_discounts_path
      expect(page.status_code).to eql(404)
    end
  end

  context "market managers" do
    let!(:user) { create(:user, :market_manager, managed_markets: [market, market2]) }

    context "plan does not allow discount codes" do
      let!(:market_org)         { create(:organization, :market, plan: startup_plan)}
      let!(:market) { create(:market, organization: market_org) }

      it "does not see Discount Codes in the menu" do
        within "#admin-nav" do
          click_link "Marketing"
        end
        expect(first(:link, "Discount Codes")).to be_nil
      end
    end

    it "can be accessed via the menu" do
      within "#admin-nav" do
        click_link "Marketing"
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
      expect(code.uses).to have_content("0")
      expect(code.available).to have_content("Unlimited")

      code = Dom::Admin::DiscountRow.find_by_name(discount_percentage.name)
      expect(code).to_not be_nil
      expect(code.code).to have_content(discount_percentage.code)
      expect(code.type).to have_content("%")
      expect(code.amount).to have_content("10.0%")
      expect(code.uses).to have_content("1")
      expect(code.available).to have_content("9")
    end

    context "Creation" do
      it "adds a new discount code" do
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

      it "displays error messages when the code is invalid" do
        visit new_admin_discount_path

        click_button "Save Discount"

        expect(page).to have_content("Error creating discount")
      end


      it "has no All Markets option" do
        visit new_admin_discount_path
        expect(find_market_options).not_to include("All Markets")
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

    context "Updating" do
      it "updates an existing discount code" do
        visit admin_discount_path(discount_fixed)

        fill_in "Name", with: "Black Friday"

        click_button "Save Discount"

        expect(page).to have_content("Successfully updated discount")
        expect(Dom::Admin::DiscountRow.all.count).to eql(2)
        expect(Dom::Admin::DiscountRow.find_by_name("Black Friday")).to_not be_nil
      end

      it "displays error messages when the code is invalid" do
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
      within "#admin-nav" do
        click_link "Marketing"
      end
      click_link "Discount Codes"

      expect(page).to have_content("Add New Discount")
    end

    it "shows a list of discount codes" do
      visit admin_discounts_path

      expect(Dom::Admin::DiscountRow.all.count).to eql(3)

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

      code = Dom::Admin::DiscountRow.find_by_name(discount_percentage2.name)
      expect(code).to_not be_nil
      expect(code.code).to have_content(discount_percentage2.code)
      expect(code.type).to have_content("%")
      expect(code.amount).to have_content("25.0%")
    end

    it "has no All Markets option" do
      visit new_admin_discount_path
      expect(find_market_options).not_to include("All Markets")
    end

    context "Creation" do
      it "adds a new discount code for a specific Market" do
        visit new_admin_discount_path

        fill_in "Name", with: "Anniversary Celebration"
        fill_in "Code", with: "CELEBRATE3"
        select market3.name, from: "Market"
        select "Percentage", from: "Type"
        fill_in "Discount", with: "30"

        click_button "Save Discount"

        expect(page).to have_content("Successfully created discount")
        expect(Dom::Admin::DiscountRow.all.count).to eql(4)
        expect(Dom::Admin::DiscountRow.find_by_name("Anniversary Celebration")).to_not be_nil
      end

      it "displays error messages when the code is invalid" do
        visit new_admin_discount_path

        click_button "Save Discount"

        expect(page).to have_content("Error creating discount")
      end
    end

    context "Deletion" do
      it "removes the discount code" do
        visit admin_discounts_path

        expect(Dom::Admin::DiscountRow.all.count).to eql(3)

        code = Dom::Admin::DiscountRow.find_by_name(discount_fixed.name)
        code.click_delete

        expect(page).to have_content("Successfully removed discount")
        expect(Dom::Admin::DiscountRow.all.count).to eql(2)

        expect(Dom::Admin::DiscountRow.find_by_name(discount_fixed.name)).to be_nil
      end
    end

    context "Updation" do
      it "updates an existing discount code" do
        visit admin_discount_path(discount_fixed)

        fill_in "Name", with: "Black Friday"

        click_button "Save Discount"

        expect(page).to have_content("Successfully updated discount")
        expect(Dom::Admin::DiscountRow.all.count).to eql(3)
        expect(Dom::Admin::DiscountRow.find_by_name("Black Friday")).to_not be_nil
      end

      it "displays error messages when the code is invalid" do
        visit admin_discount_path(discount_fixed)

        fill_in "Name", with: ""

        click_button "Save Discount"

        expect(page).to have_content("Error updating discount")
      end
    end
  end

  def find_market_options
    market_field = find_field("Market")
    expect(market_field).to be, "No 'Market' field on page."
    market_field.all("option").map(&:text)
  end
end
