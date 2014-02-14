
require "spec_helper"

describe "Editing a product" do
  let(:user) { create(:user) }
  let(:stub_warning) {"Your product will not appear in the Shop until all of these actions are complete"}
  let(:organization_label) { "Product Organization" }
  let(:product) { create(:product, name: "Canned Pears") }
  let!(:category_id) { product.category.id }

  describe "as a seller belonging to one organization" do
    before do
      product.organization.users << user
      sign_in_as(user)
      click_link "Products"
      click_link "Canned Pears"
    end

    context "when the product information is valid" do
      it "saves the product" do
        fill_in "Product Name", with: "Canned Peaches"
        click_button "Save Product"
        expect(find_field('Product Name').value).to eq("Canned Peaches")
        expect(find_field('Category').value).to eq(category_id.to_s)
      end
    end

    context "when the product information is not valid" do
      it "shows an error" do
        fill_in "Product Name", with: ""
        click_button "Save Product"

        expect(page).to have_content("Name can't be blank")
      end
    end

    context "and switching to simple inventory management", js: true do
      let(:product) { create(:product, name: "Canned Pears", use_simple_inventory: false) }

      context "with available inventory" do
        before do
          product.lots.create!(quantity: 42)
          visit admin_product_path(product)
        end

        it "user sees a warning message" do
          expect(page).to have_content("To use simple inventory management you must clear out your current available inventory")
        end

        it "user can't check simple inventory" do
          expect(page).to have_css("#product_use_simple_inventory[disabled]")
        end
      end

      context "with no available inventory", js: true do
        it "user can select simple inventory and set a simple inventory value" do
          expect(page).to_not have_content("Your current inventory")

          check 'Use simple inventory'
          fill_in 'Your current inventory', with: '42'
          click_button 'Save Product'

          expect(page).to have_content("Saved Canned Pears")
          expect(find_field("Your current inventory").value).to eq('42')
        end
      end
    end

    context "and switching to advanced inventory management", js: true do
      it "toggles display of inventory tab" do
        expect(page).to have_content("Your current inventory")
        within(".tabs") do
          expect(page).to_not have_content("Inventory")
        end

        uncheck "Use simple inventory management"

        expect(page).to_not have_content("Your current inventory")
        within(".tabs") do
          expect(page).to have_content("Inventory")
        end
      end
    end
  end
end
