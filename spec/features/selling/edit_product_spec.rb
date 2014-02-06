
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
  end
end
