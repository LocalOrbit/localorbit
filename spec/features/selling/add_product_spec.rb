require "spec_helper"

describe "Adding a product" do
  let(:user) { create(:user) }
  let(:org) { create(:organization) }
  let(:stub_warning) {"Your product will not appear in the Shop until all of these actions are complete"}
  let(:organization_label) { "Product Organization" }

  describe "as a seller belonging to one organization" do
    before do
      org.users << user
      sign_in_as(user)
      click_link "Products"
      click_link "Add a product"
    end

    context "using the choose category typeahead", js: true do
      let(:category_select) { Dom::CategorySelect.first }

      it "can quickly drill down to a result" do
        category_select.click

        expect(category_select.visible_options).to have_text("Macintosh Apples")
        expect(category_select.visible_options).to have_text("Turnips")

        category_select.type_search("grapes")

        expect(category_select.visible_options).to have_text("Red Grapes")
        expect(category_select.visible_options).to have_text("Green Grapes")
        expect(category_select.visible_options).to_not have_text("Turnips")
        expect(category_select.visible_options).to_not have_text("Macintosh Apples")

        category_select.visible_option("Fruits / Grapes / Red Grapes").click

        # Set the product name so we have a valid product
        fill_in "Product Name", with: "Red Grapes"

        click_button "Add Product"

        expect(page).to have_content("Added Red Grapes")
        expect(page).to have_content("Fruits / Grapes / Red Grapes")
      end

      it "pre-populates based on the product name" do
        expect(category_select.visible_options.count).to eql(0)

        fill_in "Product Name", with: "Red"

        category_select.click
        expect(category_select.search_field.value).to eql("Red")
        expect(category_select.visible_options).to have_text("Red Grapes")
        expect(category_select.visible_options).to have_text("Red Raspberries")
        expect(category_select.visible_options).to_not have_text("Citrus")
        expect(category_select.visible_options).to_not have_text("Apples")

        fill_in "Product Name", with: "Red Grapes"

        category_select.visible_option("Fruits / Grapes / Red Grapes").click

        click_button "Add Product"

        expect(page).to have_content("Added Red Grapes")
        expect(page).to have_content("Fruits / Grapes / Red Grapes")
      end

      it "does not pre-populate with a product name that results in no results" do
        fill_in "Product Name", with: "November Rail"

        category_select.click
        expect(category_select.visible_options.count).to eql(69)
        expect(category_select.search_field.value).to be_blank
      end
    end

    context "when all input is valid" do
      it "saves the product stub" do
        expect(page).to have_content(stub_warning)
        expect(page).to_not have_content(organization_label)

        fill_in "Product Name", with: "Macintosh Apples"
        select "Fruits / Apples / Macintosh Apples", from: "Category"

        click_button "Add Product"

        expect(page).to have_content("Added Macintosh Apples")
        expect(page).to have_content(stub_warning)
      end
    end

    context "when the product information is invalid" do
      it "does not create the product" do
        click_button "Add Product"
        expect(page).to have_content("Name can't be blank")
        expect(page).to have_content("Category can't be blank")
      end
    end
  end

  describe "as a seller belonging to multiple organizations" do
    let(:org2) { create(:organization) }

    before do
      org.users << user
      org2.users << user
      sign_in_as(user)
      click_link "Products"
      click_link "Add a product"
    end

    context "when product information is valid" do
      it "makes the user choose an organization to add the product for" do
        expect(page).to have_content(stub_warning)
        select org2.name, from: organization_label
        fill_in "Product Name", with: "Macintosh Apples"
        select "Fruits / Apples / Macintosh Apples", from: "Category"

        click_button "Add Product"

        expect(page).to have_content("Added Macintosh Apples")
        expect(page).to have_content(stub_warning)
        expect(Product.last.organization).to eql(org2)
      end
    end

    context "When no organization has been chosen" do
      it "does not create the product" do
        fill_in "Product Name", with: "Macintosh Apples"
        select "Fruits / Apples / Macintosh Apples", from: "Category"

        click_button "Add Product"
        expect(page).to have_content("Organization can't be blank")
      end
    end
  end

  describe "as a market manager" do
    let(:user) { create(:user, :market_manager) }
    let(:market) { user.managed_markets.first }
    let(:org2) { create(:organization) }

    before do
      market.organizations << org
      market.organizations << org2

      sign_in_as(user)
      click_link "Products"
      click_link "Add a product"
    end

    it "makes the user choose an organization to add the product for" do
      expect(page).to have_content(stub_warning)
      select org2.name, from: organization_label
      fill_in "Product Name", with: "Macintosh Apples"
      select "Fruits / Apples / Macintosh Apples", from: "Category"

      click_button "Add Product"

      expect(page).to have_content("Added Macintosh Apples")
      expect(page).to have_content(stub_warning)
      expect(Product.last.organization).to eql(org2)
    end
  end
end
