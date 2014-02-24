require "spec_helper"

describe "Editing advanced inventory" do
  let(:user) { create(:user) }
  let(:product){ create(:product, use_simple_inventory: false) }
  let!(:lot) { create(:lot, product:product, quantity: 93) }
  let!(:lot2) { create(:lot, product:product, quantity: 88) }

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

    describe "then clicking on another lot row" do
      it "will not open the other lot row" do
        Dom::LotRow.all.last.click

        expect(Dom::LotRow.first).to be_editable
        expect(Dom::LotRow.all.last).to_not be_editable
      end
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

        it "hides the form" do
          expect(Dom::LotRow.first).to_not be_editable
        end

        it "shows the new lot form" do
          expect(Dom::NewLotForm.first).to be_editable
        end
      end

      context "lot is invalid" do
        let(:expires_at_date) { 1.week.from_now }

        before do
          fill_in("lot_#{lot.id}_quantity", with: "9999")
          fill_in("lot_#{lot.id}_expires_at", with:expires_at_date)

          click_button "Save"
        end

        it "does not fill in the new lot fields" do
          new_lot_form = Dom::NewLotForm.first

          expect(new_lot_form.expires_at.value).to be_blank
          expect(new_lot_form.quantity.value).to be_blank
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

        it "allows the user cancel editing multiple times" do
          click_link "Cancel"
          expect(Dom::LotRow.first).not_to be_editable
          Dom::LotRow.first.click
          expect(Dom::LotRow.first).to be_editable
          click_link "Cancel"
          expect(Dom::LotRow.first).not_to be_editable
        end

        it "fills in date fields with the correct format" do
          expires_at = Dom::LotRow.first.find("#lot_#{lot.id}_expires_at").value
          expect(expires_at).to eql(expires_at_date.strftime("%a, %0e %b %Y"))
        end
      end

    end
  end
end
