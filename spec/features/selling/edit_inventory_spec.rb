require "spec_helper"

describe "Editing inventory" do
  let(:user) { create(:user) }
  let(:product) { create(:product, use_simple_inventory: false) }
  let!(:lot) { create(:lot, product: product, quantity: 93) }
  let!(:lot2) { create(:lot, product: product, quantity: 88) }
  let(:market)  { create(:market, organizations: [product.organization]) }

  let(:new_lot_form_id) { "#p#{product.id}_new_lot" }

  before do
    switch_to_subdomain(market.subdomain)
    product.organization.users << user
    sign_in_as(user)
    within "#admin-nav" do
      click_link "Products"
    end
    click_link product.name
    click_link "Inventory"
    find(:css, ".adv_inventory").click
  end

  describe "displays the new lot form", js: true do
    it "by clicking the add lot button" do
      within new_lot_form_id do
        click_link "Add Lot"
      end
      expect(".add-row").to be
    end
  end

  describe "clicking on a lot row", js: true do
    before do
      find(:css, ".adv_inventory").click
      Dom::LotRow.first.click_number
    end

    it "disables the new_lot form fields" do
      expect(".add-row.is-hidden").to be
    end

    it "opens the clicked on lot row to editing" do
      edit_lot_form = Dom::LotRow.first

      expect(edit_lot_form).to be_editable
    end

    it "changes the action and method for the form" do
      form = page.find(new_lot_form_id)
      hidden_method = page.find("[name=_method]", visible: false)

      uri = URI.parse(form["action"])
      expect(uri.path).to eql("/admin/products/#{product.id}/lots/#{lot.id}")
      expect(hidden_method.value).to eql("put")
    end

    describe "then clicking on another lot row" do
      it "will change the row being edited" do
        fill_in("lot_#{lot.id}_number", with: 55)
        Dom::LotRow.all.last.click_number

        expect(Dom::LotRow.first).to_not be_editable
        expect(Dom::LotRow.all.last).to be_editable

        Dom::LotRow.first.click_number
        expect(find_field("lot_#{lot.id}_number").value).to eq("55")
      end
    end

    describe "then canceling" do
      let(:lot_row) { Dom::LotRow.first }

      before do
        click_button("Cancel")
      end

      it "replaces the open field with the previous table row" do
        lot_row = Dom::LotRow.first
        expect(lot_row).to_not be_editable
      end

      it "sets the form url back" do
        form = page.find(new_lot_form_id)
        uri = URI.parse(form["action"])
        expect(uri.path).to eql("/admin/products/#{product.id}/lots")
        expect(form["method"]).to eql("post")
      end

      it "restores the fields to their original state" do
        lot_row = Dom::LotRow.first
        lot_row.click_number

        lot_row.inputs.each do |input|
          expect(input["disabled"]).to be_falsey
          expect(input["readonly"]).to be_falsey
        end

        fill_in("lot_#{lot.id}_number", with: 55)
        fill_in("lot_#{lot.id}_quantity", with: 66)

        click_button "Cancel"

        Dom::LotRow.first.click_number

        expect(page.find("#lot_#{lot.id}_number").value).to be_blank
        expect(page.find("#lot_#{lot.id}_quantity").value).to eql("93")
      end
    end

    describe "submitting the form" do
      context "lot is valid" do
        before do
          fill_in("lot_#{lot.id}_quantity", with: 66)
          click_button "Save"
        end

        it "saves the lot" do
          lot_row = Dom::LotRow.first
          expect(lot_row.quantity).to eql("66")
          expect(page).to have_content("Successfully saved lot")
        end

        it "hides the form" do
          expect(Dom::LotRow.first).to_not be_editable
        end

        it "does not show the new lot form" do
          expect(".add-row.is-hidden").to be
        end
      end

      context "lot is invalid", js: true do
        let(:expires_at_date) { 1.week.from_now }

        before do
          find(:css, ".adv_inventory").click

          lot_row = Dom::LotRow.first
          lot_row.click_number

          fill_in("lot_#{lot.id}_quantity", with: "9999")
          fill_in("lot_#{lot.id}_expires_at", with: expires_at_date)

          click_button "Save"
        end

        xit "responds with an error message" do
          expect(page).to have_content("Could not save lot")
          expect(page).to have_content("Lot # can't be blank when 'Expiration Date' is present")
        end

        xit "opens the lot row for editing" do
          lot_row = Dom::LotRow.first
          expect(lot_row).to be_editable

          quantity_field = lot_row.node.find("#lot_#{lot.id}_quantity")
          expect(quantity_field.value).to eql("9999")
        end

        xit "allows the user cancel editing multiple times" do
          lot_row = Dom::LotRow.first
          click_button "Cancel"
          expect(lot_row).not_to be_editable
          lot_row.click_number
          expect(lot_row).to be_editable
          click_button "Cancel"
          expect(lot_row).not_to be_editable
        end

        xit "fills in date fields with the correct format" do
          expires_at = Dom::LotRow.first.find("#lot_#{lot.id}_expires_at").value
          expect(expires_at).to eql(expires_at_date.strftime("%-d %b %Y"))
        end
      end

    end
  end
end
