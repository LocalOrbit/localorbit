require "spec_helper"

describe "Editing advanced inventory" do
  let(:user) { create(:user) }
  let(:product){ create(:product, use_simple_inventory: false) }
  let!(:lot) { create(:lot, product:product, quantity: 93) }

  before do
    product.organization.users << user
    sign_in_as(user)
    click_link "Products"
    click_link product.name
    click_link "Inventory"
  end

  describe "clicking on a lot row", js:true do
    before do
      Dom::LotRow.first.click
    end

    it "disables the new_lot form fields" do
      new_lot_form = Dom::NewLotForm.first

      new_lot_form.inputs.each do |input|
        expect(input['disabled']).to eql('disabled')
        expect(input['readonly']).to eql('readonly')
      end
    end

    it "opens the clicked on lot row to editing" do
      edit_lot_form = Dom::LotRow.first

      expect(edit_lot_form).to be_editable
    end

    it "changes the action and method for the form" do
      form = page.find("#new_lot")
      hidden_method = page.find("[name=_method]", visible:false)

      expect(form['action']).to eql("/admin/products/#{product.id}/lots/#{lot.id}")
      expect(hidden_method.value).to eql("put")
    end

    describe "then canceling" do
      let(:lot_row) { Dom::LotRow.first }

      before do
        lot_row.node.find_link("Cancel").click
      end

      it "replaces the open field with the previous table row" do
        lot_row = Dom::LotRow.first
        expect(lot_row).to_not be_editable
      end

      it "enables the new lot form" do
        new_lot_form = Dom::NewLotForm.first

        new_lot_form.inputs.each do |input|
          expect(input['disabled']).to be_nil
          expect(input['readonly']).to be_nil
        end
      end

      it "sets the form url back" do
        form = page.find("#new_lot")
        expect(form['action']).to eql("/admin/products/#{product.id}/lots")
        expect(form['method']).to eql("post")
      end

      it "restores the fields to their original state" do
        lot_row = Dom::LotRow.first
        lot_row.click

        lot_row.inputs.each do |input|
          expect(input['disabled']).to be_nil
          expect(input['readonly']).to be_nil
        end

        fill_in("lot_#{lot.id}_number", with: 55)
        fill_in("lot_#{lot.id}_quantity", with: 66)

        click_link "Cancel"

        Dom::LotRow.first.click

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

        it "hides the form"
        it "shows the new lot form"
      end

      context "lot is invalid" do
        before do
          fill_in("lot_#{lot.id}_quantity", with: "9999")
          fill_in("lot_#{lot.id}_expires_at", with:1.week.from_now)

          click_button "Save"
        end

        it "responds with an error message" do
          expect(page).to have_content("Could not save lot")
          expect(page).to have_content("Lot # can't be blank when 'Expiration Date' is present")
        end

        it "opens the lot row for editing" do
          lot_row = Dom::LotRow.first
          expect(lot_row).to be_editable

          quantity_field = lot_row.node.find("#lot_#{lot.id}_quantity")
          expect(quantity_field.value).to eql("9999")
        end
      end

    end
  end
end
