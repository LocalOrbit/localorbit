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

    context "when all input is valid" do
      it "saves the product stub" do
        expect(page).to have_content(stub_warning)
        expect(page).to_not have_content(organization_label)

        fill_in "Product Name", with: "Macintosh Apples"
        select "Fruits > Apples > Macintosh Apples", from: "Category"

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
        select "Fruits > Apples > Macintosh Apples", from: "Category"

        click_button "Add Product"

        expect(page).to have_content("Added Macintosh Apples")
        expect(page).to have_content(stub_warning)
        expect(Product.last.organization).to eql(org2)
      end
    end

    context "When no organization has been chosen" do
      it "does not create the product" do
        fill_in "Product Name", with: "Macintosh Apples"
        select "Fruits > Apples > Macintosh Apples", from: "Category"

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
      select "Fruits > Apples > Macintosh Apples", from: "Category"

      click_button "Add Product"

      expect(page).to have_content("Added Macintosh Apples")
      expect(page).to have_content(stub_warning)
      expect(Product.last.organization).to eql(org2)
    end
  end
end
