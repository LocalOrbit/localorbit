require "spec_helper"

describe "Checking Out", js: true do
  def kale_item
    Dom::Cart::Item.find_by_name("Kale")
  end

  def bananas_item
    Dom::Cart::Item.find_by_name("Bananas")
  end

  def potatoes_item
    Dom::Cart::Item.find_by_name("Potatoes")
  end

  let(:user) { create(:user) }
  let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }

  let!(:seller) { create(:organization, :seller, name: "Fulton St. Farms") }
  let!(:seller2){ create(:organization, :seller, name: "Ada Farms") }

  let(:market) { create(:market, :with_addresses, organizations: [buyer, seller, seller2]) }
  let!(:pickup) { create(:delivery_schedule, :buyer_pickup, market: market) }
  let!(:delivery) { create(:delivery_schedule, :percent_fee,  market: market) }

  # Fulton St. Farms (seller)
  let!(:bananas) { create(:product, :sellable, name: "Bananas", organization: seller) }
  let!(:bananas_price_buyer_base) {
    create(:price, market: market, product: bananas, min_quantity: 1, organization: buyer, sale_price: 0.50)
  }

  let!(:kale) { create(:product, :sellable, name: "Kale", organization: seller) }
  let!(:kale_price_tier1) {
    create(:price, market: market, product: kale, min_quantity: 4, sale_price: 2.50)
  }

  let!(:kale_price_tier2) {
    create(:price, market: market, product: kale, min_quantity: 6, sale_price: 1.00)
  }

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

  def sign_in_and_choose_delivery(delivery=nil)
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
    find(:link, "Shop").trigger("click")
    sleep(0.5)
    choose_delivery(delivery)
  end

  def add_items
    expect(page).to have_content("Bananas")
    expect(page).to have_content("Kale")
    expect(page).to have_content("Potatoes")

    # Bananas Price for this buyer: 0.50
    # Total: 10 * 0.50 = 5.00
    Dom::Cart::Item.find_by_name("Bananas").set_quantity("10")
    Dom::Cart::Item.find_by_name("Kale").node.click

    # Potatoes Price for this everyone: 3.00
    # Total: 5 * 3.00 = 15.00
    Dom::Cart::Item.find_by_name("Potatoes").set_quantity("5")
    Dom::Cart::Item.find_by_name("Kale").node.click

    # Kale Price for this at >6 everyone: 1.00
    # Total: 20 * 1.00 (>6) = 20.00
    Dom::Cart::Item.find_by_name("Kale").set_quantity("20")
    Dom::Cart::Item.find_by_name("Bananas").node.click

    sleep(1)
  end

  context "common functionality" do
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
      expect(bananas_item.quantity.value).to eql("10")
      expect(kale_item.quantity.value).to eql("20")
      expect(potatoes_item.quantity.value).to eql("5")
    end
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

  context "delivery fees" do
    it "show in the totals" do
      sign_in_and_choose_delivery "Delivery: May 13, 2014 between 7:00AM and 11:00AM"
      cart_link.node.click

      expect(Dom::Cart::Totals.first.delivery_fees).to have_content("$0.00")

      click_link "Shop"
      add_items

      cart_link.node.click
      expect(Dom::Cart::Totals.first.delivery_fees).to have_content("$10.00")

      kale_item.set_quantity(98)
      bananas_item.quantity_field.click
      sleep(0.5)

      expect(Dom::Cart::Totals.first.delivery_fees).to have_content("$29.50")
    end

    context "when there are no delivery fees" do
      it "displays as 'Free!'" do
        sign_in_and_choose_delivery "Pick Up: May 13, 2014 between 10:00AM and 12:00PM"
        cart_link.node.click

        expect(Dom::Cart::Totals.first.delivery_fees).to have_content("Free!")

        click_link "Shop"
        add_items

        cart_link.node.click
        expect(Dom::Cart::Totals.first.delivery_fees).to have_content("Free!")

        kale_item.set_quantity(98)
        bananas_item.quantity_field.click
        sleep(0.5)

        expect(Dom::Cart::Totals.first.delivery_fees).to have_content("Free!")
      end
    end
  end

  context "total" do
    it "is the subtotal plus delivery fees" do
      sign_in_and_choose_delivery "Delivery: May 13, 2014 between 7:00AM and 11:00AM"
      cart_link.node.click

      expect(Dom::Cart::Totals.first.total).to have_content("$0.00")

      click_link "Shop"
      add_items

      cart_link.node.click
      expect(Dom::Cart::Totals.first.total).to have_content("$50.00")

      kale_item.set_quantity(98)
      bananas_item.quantity_field.click
      sleep(0.5)

      expect(Dom::Cart::Totals.first.total).to have_content("$147.50")
    end
  end

  context "updating quantity" do
    def cart_totals
      Dom::Cart::Totals.first
    end

    before do
      sign_in_and_choose_delivery
      add_items
      cart_link.node.click # This behavior will change once the cart preview is implemented
      expect(page).to have_content("Your Order")

      kale_item.set_quantity(4)
      bananas_item.quantity_field.click
    end

    it "updates the cart item" do
      visit "/cart"
      expect(kale_item.quantity_field.value).to eql("4")
    end

    it "updates the per-unit price based on the pricing tier it fits in" do
      expect(kale_item.price_for_quantity).to have_content("$2.50")

      kale_item.set_quantity(98)
      bananas_item.quantity_field.click
      expect(kale_item.price_for_quantity).to have_content("$1.00")

      kale_item.set_quantity(4)
      bananas_item.quantity_field.click
      expect(kale_item.price_for_quantity).to have_content("$2.50")

      kale_item.set_quantity(5)
      bananas_item.quantity_field.click
      expect(kale_item.price_for_quantity).to have_content("$2.50")

      kale_item.set_quantity(1)
      bananas_item.quantity_field.click
      expect(kale_item.price_for_quantity).to have_content("$3.00")

      kale_item.set_quantity(0)
      bananas_item.quantity_field.click
      expect(kale_item.price_for_quantity).to have_content("$3.00")
    end

    it "updates the overall price" do
      expect(kale_item.price).to have_content("$10.00")

      kale_item.set_quantity(98)
      bananas_item.quantity_field.click
      expect(kale_item.price).to have_content("$98.00")

      kale_item.set_quantity(4)
      bananas_item.quantity_field.click
      expect(kale_item.price).to have_content("$10.00")

      kale_item.set_quantity(5)
      bananas_item.quantity_field.click
      expect(kale_item.price).to have_content("$12.50")

      kale_item.set_quantity(1)
      bananas_item.quantity_field.click
      expect(kale_item.price).to have_content("$3.00")

      kale_item.set_quantity(0)
      bananas_item.quantity_field.click
      expect(kale_item.price).to have_content("$0.00")
    end

    it "updates item subtotal" do
      expect(cart_totals.subtotal).to have_content("$30.00")

      kale_item.set_quantity(98)
      bananas_item.quantity_field.click

      expect(cart_totals.subtotal).to have_content("$118.00")
    end
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
