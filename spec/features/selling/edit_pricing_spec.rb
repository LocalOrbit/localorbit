require "spec_helper"

describe "Editing advanced pricing", js: true do
  let!(:market)       { create(:market) }
  let!(:organization) { create(:organization, markets: [market]) }
  let!(:user)         { create(:user, organizations: [organization]) }
  let!(:product)      { create(:product, organization: organization) }
  let!(:price)        { create(:price, product: product, sale_price: 3) }
  let!(:price2)       { create(:price, product: product, sale_price: 2, min_quantity: 100) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
    within "#admin-nav" do
      click_link "Products"
    end
    click_link product.name
    click_link "Pricing"
  end

  describe "clicking on a price row" do
    before do
      Dom::PricingRow.first.click_edit
    end

    it "opens the clicked on price row to editing" do
      edit_price_form = Dom::PricingRow.first

      expect(edit_price_form).to be_editable
    end

    it "changes the action and method for the form" do
      form = page.find("#new_price")
      hidden_method = page.find("[name=_method]", visible: false)

      expect(form["action"]).to eql("/admin/products/#{product.id}/prices/#{price.id}")
      expect(hidden_method.value).to eql("put")
    end

    describe "then clicking on another price row" do
      it "will change the row being edited" do
        fill_in("price_#{price.id}_sale_price", with: 55)
        Dom::PricingRow.all.last.click_buyer

        expect(Dom::PricingRow.first).to_not be_editable
        expect(Dom::PricingRow.all.last).to be_editable

        Dom::PricingRow.first.click_buyer
        expect(find_field("price_#{price.id}_sale_price").value).to eq("55.00")
      end
    end

    describe "then canceling" do
      let(:price_row) { Dom::PricingRow.first }

      before do
        price_row.node.find_button("Cancel").click
      end

      it "replaces the open field with the previous table row" do
        price_row = Dom::PricingRow.first
        expect(price_row).to_not be_editable
      end

      it "sets the form url back" do
        form = page.find("#new_price")
        expect(form["action"]).to eql("/admin/products/#{product.id}/prices")
        expect(form["method"]).to eql("post")
      end

      it "restores the fields to their original state" do
        price_row = Dom::PricingRow.first
        price_row.click_buyer

        price_row.inputs.each do |input|
          expect(input["disabled"]).to be_nil
          expect(input["readonly"]).to be_nil
        end

        fill_in("price_#{price.id}_sale_price", with: 55)
        fill_in("price_#{price.id}_min_quantity", with: 66)

        click_button "Cancel"

        Dom::PricingRow.first.click_buyer

        expect(page.find("#price_#{price.id}_sale_price").value).to eql("3.00")
        expect(page.find("#price_#{price.id}_min_quantity").value).to eql("1")
      end
    end

    describe "submitting the form" do
      context "sale price is valid" do
        before do
          fill_in("price_#{price.id}_sale_price", with: 66)
          click_button "Save"
        end

        it "saves the price" do
          price_row = Dom::PricingRow.first
          expect(price_row.sale_price).to eql("$66.00")
          expect(page).to have_content("Successfully saved price")
        end

        it "hides the form" do
          expect(Dom::PricingRow.first).to_not be_editable
        end
      end

      context "sale_price is invalid" do
        before do
          fill_in("price_#{price.id}_sale_price", with: "-10")
          fill_in("price_#{price.id}_min_quantity", with: "-2")

          click_button "Save"
        end

        it "responds with an error message" do
          expect(page).to have_content("Could not save price")
          expect(page).to have_content("Minimum quantity must be greater than 0")
        end

        it "opens the price row for editing" do
          price_row = Dom::PricingRow.first
          expect(price_row).to be_editable

          sale_price_field = price_row.node.find("#price_#{price.id}_sale_price")
          expect(sale_price_field.value).to eql("-10.00")
        end

        it "allows the user cancel editing multiple times" do
          click_button "Cancel"
          expect(Dom::PricingRow.first).not_to be_editable
          Dom::PricingRow.first.click_buyer
          expect(Dom::PricingRow.first).to be_editable
          click_button "Cancel"
          expect(Dom::PricingRow.first).not_to be_editable
        end

        it "calculates and formats the net price" do
          price_row = Dom::PricingRow.first
          net_price = price_row.node.find("#price_#{price.id}_net_price")
          expect(net_price.value).to eql("-9.41") # appropriate fees
        end
      end

    end
  end

  describe "deleting a price" do
    it "allows the user to delete multiple prices" do
      Dom::PricingRow.all.each {|p| p.check_delete }
      click_button "Delete Selected Prices"

      expect(page).to have_content("Successfully removed prices")
      expect(Dom::PricingRow.all).to be_empty
    end

    it "selecting all prices" do
      find(".select-all").click

      all("td:first-child input").each do |field|
        expect(field).to be_checked
      end

      click_button "Delete Selected Prices"

      expect(page).to have_content("Successfully removed prices")
      expect(Dom::PricingRow.all).to be_empty
    end
  end

  describe "with different fees", js: true do
    let(:market) { create(:market, local_orbit_seller_fee: 4, market_seller_fee: 6) }
    # total fees: CC seller fee as default, plus this 10 %, so 12.9%
    it "shows updated net sale information" do
      Dom::PricingRow.first.click_edit
      fill_in "price_#{price.id}_sale_price", with: "12.90"
      expect(find_field("price_#{price.id}_net_price").value).to eq("11.24")
      click_button "Save"

      expect(page).to have_content("Successfully saved price")

      record = Dom::PricingRow.first
      expect(record.buyer).to eq("All Buyers")
      expect(record.min_quantity).to eq("1")
      expect(record.net_price).to eq("$11.24")
      expect(record.sale_price).to eq("$12.90")
    end
  end
end
