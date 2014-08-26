require "spec_helper"

feature "An Admin viewing the product taxonomy" do
  let!(:user) { create(:user, :admin) }

  scenario "navigating to the page" do
    switch_to_main_domain
    sign_in_as user
    click_link "Market Admin"
    click_link "Product Taxonomy"
    expect(page).to have_content("Product Taxonomy")
  end

  scenario "viewing the taxonomy" do
    sign_in_as user
    visit admin_categories_path
    expect(page).to have_content("Product Taxonomy")
    expect(page).to have_content("Fruit")
  end

  scenario "viewing the taxonomy as CSV" do
    sign_in_as user
    visit admin_categories_path
    click_link "Export CSV"
    expect(page).to have_content("Fruits,Apples,Golden Delicious")
  end

  scenario "viewing products for a category" do
    product = create(:product)
    sign_in_as user
    visit admin_categories_path
    click_link "1"
    expect(page).to have_content(product.category.name)
    expect(page).to have_content(product.name)
  end

  context "adding a category" do
    scenario "An admin adding a category" do
      sign_in_as user
      visit admin_categories_path
      click_link "Add New Category"
      fill_in "Name", with: "Watercress"
      select "Lettuces, Leafy Greens & Sprouts", from: "Parent"
      click_button "Add Category"
      expect(page).to have_content("Watercress")
    end

    scenario "An admin adding an invalid category" do
      sign_in_as user
      visit admin_categories_path
      click_link "Add New Category"
      fill_in "Name", with: ""
      select "Lettuces, Leafy Greens & Sprouts", from: "Parent"
      click_button "Add Category"
      expect(page).not_to have_content("Watercress")
      expect(page).to have_content("Name can't be blank")
    end
  end
end
