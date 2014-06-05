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
end