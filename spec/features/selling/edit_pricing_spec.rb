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
      form = page.find("#p#{product.id}_new_price")
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
        form = page.find("#p#{product.id}_new_price")
        expect(form["action"]).to eql("/admin/products/#{product.id}/prices")
        expect(form["method"]).to eql("post")
      end

      it "restores the fields to their original state" do
        price_row = Dom::PricingRow.first
        price_row.click_buyer

        price_row.inputs.each do |input|
          expect(input["disabled"]).to be_falsey
          expect(input["readonly"]).to be_falsey
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

          sale_price_field = price_row.node.all(".sale-price")[1]
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
          net_price = price_row.node.all(".net-price")[1]
          expect(net_price.value).to eql("-9.41") # appropriate fees
        end
      end

    end
  end

  describe "deleting a price" do
    it "allows the user to delete one of multiple prices" do
      expect(Dom::PricingRow.count).to be(2)
      first(".view-cell .delete").click

      expect(page).to have_content("Successfully removed price")
      expect(Dom::PricingRow.count).to be(1)
    end

    it "allows the user to delete all prices" do
      pending "a new design is needed for deleting all prices"

      find(".select-all").click

      all("td:first-child input").each do |field|
        expect(field).to be_checked
      end

      click_button "Delete Selected Prices"

      expect(page).to have_content("Successfully removed prices")
      # verify the pricing row remaining is an edit row, not an actual price
      expect(Dom::PricingRow.count).to be(1)
      expect(Dom::PricingRow.all_classes).to eq(["add-price add-row price"])
    end
  end

  describe "with different fees" do
    let(:market) { create(:market, local_orbit_seller_fee: 4, market_seller_fee: 6) }
    # total fees: CC seller fee as default, plus this 10 %, so 12.9%
    it "shows updated net sale information" do
      Dom::PricingRow.first.click_edit
      fill_in "price_#{price.id}_sale_price", with: "12.90"
      find("#price_#{price.id}_net_price").click
      expect(find_field("price_#{price.id}_net_price").value).to eq("11.24") # 12.9% fees deducted
      click_button "Save"

      expect(page).to have_content("Successfully saved price")

      record = Dom::PricingRow.first
      expect(record.buyer).to eq("All Buyers")
      expect(record.min_quantity).to eq("1")
      expect(record.net_price).to eq("$11.24") # 12.9% fees deducted
      expect(record.sale_price).to eq("$12.90")
    end
  end
end

describe "price estimator", js: true do
  let!(:market1) {create(:market, local_orbit_seller_fee:3, market_seller_fee:2, allow_cross_sell:true)}
  let!(:market2) {create(:market, local_orbit_seller_fee:5,market_seller_fee:10,allow_cross_sell:true)}

  let!(:org_cross_sell) {
    org = create(:organization, markets:[market1])
    org.update_cross_sells!(from_market:market1,to_ids:[market2.id])
    org
  }
  let!(:user) { create(:user, organizations: [org_cross_sell]) }
  let!(:product1) {create(:product,organization:org_cross_sell) }

  before do
    switch_to_subdomain(market1.subdomain)
    sign_in_as(user)
    within "#admin-nav" do

      click_link "Products"
    end
    click_link product1.name
    click_link "Pricing"
  end

  it "allows price adding and editing properly in both markets" do
    # Pricing adding tests
    form = Dom::NewPricingForm.first
    # DO NOT click btn add here -- there is a row already open
    within form.node do
      find("select.price_market_id").find("option[value='#{market1.id}']").select_option
      fill_in "price[sale_price]", with: "12.90"
      click_button "Add"
    end
    price_row = Dom::PricingRow.first
    expect(price_row.net_price).to eq("$11.88") # market 1, 7.9% fees deducted first

    # Pricing editing tests
    price_row.click_edit

    within price_row.node do
      find("select.price_market_id").find("option[value='#{market1.id}']").select_option
      price_row.node.find("input.sale-price").set("16.80")
      expect(price_row.node.find("input.net-price").value).to eq("15.47")

      find("select.price_market_id").find("option[value='#{market2.id}']").select_option
      price_row.node.find("input.sale-price").set("16.80")
      expect(price_row.node.find("input.net-price").value).to eq("13.79")

      find("select.price_market_id").select("All Markets")
      price_row.node.find("input.sale-price").set("16.80")
      expect(price_row.node.find("input.net-price").value).to eq("13.79")

      click_button "Save" # prep for following
    end
    price_row = Dom::PricingRow.first
    expect(price_row.net_price).to eq("$13.79")

  end
end
