require "spec_helper"

describe "Checking Out", js: true do
  let(:user) { create(:user) }
  let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }

  let!(:seller) { create(:organization, :seller, name: "Fulton St. Farms") }
  let!(:seller2){ create(:organization, :seller, name: "Ada Farms") }

  let(:market) { create(:market, :with_addresses, organizations: [buyer, seller, seller2]) }
  let!(:pickup) { create(:delivery_schedule, :buyer_pickup, market: market) }
  let!(:delivery) { create(:delivery_schedule, market: market) }

  # Fulton St. Farms (seller)
  let!(:bananas) { create(:product, :sellable, name: "Bananas", organization: seller) }
  let!(:bananas_price_buyer_base) {
    create(:price, market: market, product: bananas, min_quantity: 1, organization: buyer, sale_price: 7.00)
  }

  let!(:kale) { create(:product, :sellable, name: "Kale", organization: seller) }

  # Ada Farms (seller2)
  let!(:potatoes) { create(:product, :sellable, name: "Potatoes", organization: seller2) }
  let!(:beans) { create(:product, :sellable, name: "Beans", organization: seller2) }

  before do
    Timecop.travel("May 8, 2014")
  end

  after do
    Timecop.return
  end


  def cart_link
    Dom::CartLink.first
  end

  def sign_in_and_choose_delivery(delivery)
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
    find(:link, "Shop").trigger("click")
    choose_delivery(delivery)
  end

  def add_items
    # Bananas Price for this buyer: 7.00
    # Total: 10 * 7.00 = 70.00
    Dom::Buying::ProductRow.find_by_name("Bananas").set_quantity("10")

    # Potatoes Price for this everyone: 3.00
    # Total: 5 * 3.00 = 15.00
    Dom::Buying::ProductRow.find_by_name("Potatoes").set_quantity("5")

    # Kale Price for this everyone: 3.00
    # Total: 20 * 3.00 = 60.00
    Dom::Buying::ProductRow.find_by_name("Kale").set_quantity("20")
    Dom::Buying::ProductRow.find_by_name("Bananas").node.click
  end

  context "delivery" do
    context "is a pickup" do
      before do
        sign_in_and_choose_delivery "Pick Up: May 13, 2014 between 10:00AM and 12:00PM"
        add_items

        # NOTE: the behavior of clicking the cart link will change
        # once the cart preview has been built. See 
        # https://www.pivotaltracker.com/story/show/67553382
        cart_link.node.click # This behavior will change once the cart preview is implemented
        expect(page).to have_content("Your Order")
      end

      it "lists products grouped by organization" do
        fulton_farms = Dom::Cart::SellerGroup.find_by_seller("Fulton St. Farms")
        ada_farms = Dom::Cart::SellerGroup.find_by_seller("Ada Farms")

        expect(fulton_farms).to have_product_row("Bananas")
        expect(fulton_farms).to have_product_row("Kale")
        expect(ada_farms).to have_product_row("Potatoes")
      end

      it "lists the values for the product" do
        bananas_item = Dom::Cart::Item.find_by_name("Bananas")
        kale_item = Dom::Cart::Item.find_by_name("Kale")
        potatoes_item = Dom::Cart::Item.find_by_name("Potatoes")

        expect(bananas_item.quantity).to have_content("10")
        expect(bananas_item.unit_price).to have_content("$7.00")
        expect(bananas_item.price).to have_content("$70.00")

        expect(kale_item.quantity).to have_content("20")
        expect(kale_item.unit_price).to have_content("$3.00")
        expect(kale_item.price).to have_content("$60.00")

        expect(potatoes_item.quantity).to have_content("5")
        expect(potatoes_item.unit_price).to have_content("$3.00")
        expect(potatoes_item.price).to have_content("$15.00")
      end

      it "displays market address" do
        within("#address") do
          expect(page).to have_content("Delivery Address")
          expect(page).to have_content("Pickup on May 13, 2014 between 10:00AM and 12:00PM")
          expect(page).to have_content(market.addresses.first.address)
          expect(page).to have_content(market.addresses.first.city)
          expect(page).to have_content(market.addresses.first.state)
          expect(page).to have_content(market.addresses.first.zip)
        end
      end


      context "delivery fees" do
        context "are present" do
          it "displays the fee"
          it "modifies the total"
        end

        context "are not present" do
          it "does not modify the total"
          it "displays as Free!"
        end
      end
    end

    context "is dropoff" do
      before do
        sign_in_and_choose_delivery "Delivery: May 13, 2014 between 7:00AM and 11:00AM"
        add_items

        # NOTE: the behavior of clicking the cart link will change
        # once the cart preview has been built. See 
        # https://www.pivotaltracker.com/story/show/67553382
        cart_link.node.click # This behavior will change once the cart preview is implemented
        expect(page).to have_content("Your Order")
      end

      it "displays organization location address" do
        within("#address") do
          expect(page).to have_content("Delivery Address")
          expect(page).to have_content("Delivery on May 13, 2014 between 7:00AM and 11:00AM")
          expect(page).to have_content(market.addresses.first.address)
          expect(page).to have_content(market.addresses.first.city)
          expect(page).to have_content(market.addresses.first.state)
          expect(page).to have_content(market.addresses.first.zip)
        end
      end
    end
  end

  context "with an empty cart" do
  end

  context "updating quantity" do
    it "updates the per-unit price based on the pricing tier it fits in"
    it "updates the overall price"
    it "updates item subtotal"
    it "updates total based on discounts and delivery fees"
  end


  context "discounts" do
    context "are present" do
      it "modifies the total"
    end

    context "are not present" do
      it "does not modify the total"
    end
  end
end
