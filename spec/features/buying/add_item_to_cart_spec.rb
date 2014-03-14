require "spec_helper"

feature "Add item to cart", js:true do
  let(:user) { create(:user) }
  let(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }

  let(:seller) {create(:organization, :seller) }

  let(:market) { create(:market, :with_addresses, organizations: [buyer, seller]) }
  let!(:pickup) { create(:delivery_schedule, :buyer_pickup, market: market) }
  let!(:delivery) { create(:delivery_schedule, market: market) }

  # Producsts
  let(:bananas) { create(:product, name: "Bananas", organization: seller) }
  let!(:bananas_lot) { create(:lot, product: bananas) }
  let!(:bananas_price_buyer_base) {
    create(:price, market: market, product: bananas, min_quantity: 1, organization: buyer)
  }

  let(:bananas_price_everyone_base) {
    create(:price, market: market, product: bananas, min_quantity: 1)
  }

  let(:kale) { create(:product, name: "kale", organization: seller) }
  let!(:kale_lot) { create(:lot, product: kale) }
  let!(:kale_price_buyer_base) {
    create(:price, market: market, product: kale, min_quantity: 1)
  }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
    click_link "Shop"
    choose_delivery
  end

  scenario "with an empty cart" do
    cart_counter = Dom::Buying::CartCounter.first
    expect(cart_counter.item_count).to eql(0)

    product = Dom::Buying::ProductRow.find_by_name("Bananas")
    product.set_quantity(12)

    cart_counter.item_count.should
    expect(Dom::Buying::CartCounter.first.item_count).to eql(1)
  end

  scenario "cart already has items in it"
end
