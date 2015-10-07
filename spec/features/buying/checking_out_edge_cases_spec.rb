require "spec_helper"

describe "Checking Out", :js, :vcr do
  let!(:user) { create(:user) }
  let!(:other_buying_user) {  create(:user) }
  let!(:buyer) { create(:organization, :single_location, :buyer, users: [user, other_buying_user]) }
  let!(:credit_card)  { create(:bank_account, :credit_card, bankable: buyer) }
  let!(:bank_account) { create(:bank_account, :checking, :verified, bankable: buyer) }

  let!(:fulton_farms) { create(:organization, :seller, :single_location, name: "Fulton St. Farms", users:[create(:user), create(:user)]) }
  let!(:ada_farms){ create(:organization, :seller, :single_location, name: "Ada Farms", users: [create(:user)]) }

  let!(:market_manager) { create(:user) }
  let!(:market) { create(:market, :with_addresses, organizations: [buyer, fulton_farms, ada_farms], managers: [market_manager]) }
  let!(:delivery_schedule) { create(:delivery_schedule, :percent_fee,  order_cutoff: 24, day:1, fee:nil, market: market, day: 5, require_delivery: false, require_cross_sell_delivery: false, seller_delivery_start: "8:00 AM", seller_delivery_end: "5:00 PM", buyer_pickup_location_id: 0, buyer_pickup_start: "12:00 AM", buyer_pickup_end: "12:00 AM", market_pickup: false) }
  let!(:delivery_schedule2) { create(:delivery_schedule, :percent_fee,  order_cutoff: 24, day:2, fee:nil, market: market, day: 5, require_delivery: false, require_cross_sell_delivery: false, seller_delivery_start: "8:00 AM", seller_delivery_end: "5:00 PM", buyer_pickup_location_id: 0, buyer_pickup_start: "12:00 AM", buyer_pickup_end: "12:00 AM", market_pickup: false) }


  # Fulton St. Farms
  let!(:bananas) { create(:product, :sellable, name: "Bananas", organization: fulton_farms) }
  let!(:bananas_lot) { create(:lot, product: bananas, quantity: 100) }
  let!(:bananas_price_buyer_base) {
    create(:price, :past_price, market: market, product: bananas, min_quantity: 1, organization: buyer, sale_price: 0.50)
  }

  let!(:kale) { create(:product, :sellable, name: "Kale", organization: fulton_farms) }
  let!(:kale_lot) { kale.lots.first.update_attribute(:quantity, 100) }
  let!(:kale_price_tier1) {
    create(:price, :past_price, market: market, product: kale, min_quantity: 4, sale_price: 2.50)
  }

  let!(:kale_price_tier2) {
    create(:price, :past_price, market: market, product: kale, min_quantity: 6, sale_price: 1.00)
  }

  # Ada Farms
  let!(:potatoes) { create(:product, :sellable, name: "Potatoes", organization: ada_farms) }
  let!(:potatoes_lot) { create(:lot, product: potatoes, quantity: 100) }

  let!(:beans) { create(:product, :sellable, name: "Beans", organization: ada_farms) }

  def cart_link
    Dom::CartLink.first
  end

  before do
    Timecop.travel(DateTime.now - delivery_schedule.order_cutoff - 25.hours)
  end

  after do
    Timecop.return
  end

  def checkout
    click_button "Place Order"
  end

=begin
  context "user enters items into cart before cutoff, then cutoff time lapses, then the user checks out", :js do
    it "shows them an error" do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)

      choose_delivery

      Dom::Cart::Item.find_by_name("Bananas").set_quantity(12)
      expect(page).to have_content("Added to cart!")
      expect(page).to_not have_content("Added to cart!")
      expect(page).to have_text("Cart 1")

      cart_link.node.click

      # Travel to a few minutes after the cutoff
      Timecop.travel((Delivery.last.cutoff_time + 8.minutes).to_s)
      sign_in_as(user)

      choose "Pay by Purchase Order"
      fill_in "PO Number", with: "12345"

      checkout

      expect(page).to have_content("Ordering for your selected pickup or delivery date ended")
    end
  end
=end
end
