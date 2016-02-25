require "spec_helper"

feature "Deleting a product from the product list" do

  let!(:market_manager) { create(:user, :market_manager) }
  let!(:market) { market_manager.managed_markets.first }
  let!(:org1) { create(:organization, :seller, markets: [market]) }
  let!(:product1) { create(:product, organization: org1) }
  let!(:product2) { create(:product, organization: org1) }
  let!(:user) { create(:user, :supplier, organizations: [org1]) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  scenario "soft deletes a product" do
    visit admin_products_path

    product = Dom::ProductRow.first
    #page.execute_script("$('.fa-trash-o').first().click()")
    product.click_delete

    expect(Dom::ProductRow.count).to eq(1)
    expect(page).to have_content("Successfully deleted #{product.name}")
    expect(Product.find_by(name: product.name).deleted_at).to_not be_nil
  end
end
