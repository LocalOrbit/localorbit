require "spec_helper"

describe "Checking Out", js: true do
  let!(:user) { create(:user) }
  let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }

  let!(:fulton_farms) { create(:organization, :seller, :single_location, name: "Fulton St. Farms") }
  let!(:ada_farms){ create(:organization, :seller, :single_location, name: "Ada Farms") }

  let(:market) { create(:market, :with_addresses, organizations: [buyer, fulton_farms, ada_farms]) }
  let(:delivery_schedule) { create(:delivery_schedule, :percent_fee,  market: market, day: 5) }
  let(:delivery_day) { DateTime.parse("May 9, 2014, 11:00:00") }
  let(:delivery) {
    create(:delivery,
      delivery_schedule: delivery_schedule,
      deliver_on: delivery_day,
      cutoff_time:delivery_day - delivery_schedule.order_cutoff.hours
    )
  }

  # Fulton St. Farms
  let!(:bananas) { create(:product, :sellable, name: "Bananas", organization: fulton_farms) }
  let!(:bananas_lot) { create(:lot, product: bananas, quantity: 100) }
  let!(:bananas_price_buyer_base) {
    create(:price, market: market, product: bananas, min_quantity: 1, organization: buyer, sale_price: 0.50)
  }

  let!(:kale) { create(:product, :sellable, name: "Kale", organization: fulton_farms) }
  let!(:kale_lot) { kale.lots.first.update_attribute(:quantity, 100) }
  let!(:kale_price_tier1) {
    create(:price, market: market, product: kale, min_quantity: 4, sale_price: 2.50)
  }

  let!(:kale_price_tier2) {
    create(:price, market: market, product: kale, min_quantity: 6, sale_price: 1.00)
  }

  # Ada Farms
  let!(:potatoes) { create(:product, :sellable, name: "Potatoes", organization: ada_farms) }
  let!(:pototoes_lot) { create(:lot, product: potatoes, quantity: 100) }

  let!(:beans) { create(:product, :sellable, name: "Beans", organization: ada_farms) }

  let!(:cart) { create(:cart, market: market, organization: buyer, location: buyer.locations.first, delivery: delivery) }
  let!(:cart_bananas) { create(:cart_item, cart: cart, product: bananas, quantity: 10) }
  let!(:cart_potatoes) { create(:cart_item, cart: cart, product: potatoes, quantity: 5) }
  let!(:cart_kale) { create(:cart_item, cart: cart, product: kale, quantity: 20) }

  before do
    Timecop.travel("May 5, 2014")
  end

  after do
    Timecop.return
  end

  def bananas_item
    Dom::Cart::Item.find_by_name("Bananas")
  end

  def cart_link
    Dom::CartLink.first
  end

  def cart_totals
    Dom::Cart::Totals.first
  end

  def kale_item
    Dom::Cart::Item.find_by_name("Kale")
  end

  def potatoes_item
    Dom::Cart::Item.find_by_name("Potatoes")
  end

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)

    # NOTE: the behavior of clicking the cart link will change
    # once the cart preview has been built. See
    # https://www.pivotaltracker.com/story/show/67553382
    cart_link.node.click # This behavior will change once the cart preview is implemented
    expect(page).to have_content("Your Order")
  end

  it "lists products grouped by organization" do
    fulton_farms_group = Dom::Cart::SellerGroup.find_by_seller("Fulton St. Farms")
    ada_farms_group = Dom::Cart::SellerGroup.find_by_seller("Ada Farms")

    expect(fulton_farms_group).to have_product_row("Bananas")
    expect(fulton_farms_group).to have_product_row("Kale")
    expect(ada_farms_group).to have_product_row("Potatoes")
  end

  it "displays the current cart item quantities" do
    expect(bananas_item.quantity.value).to eql("10")
    expect(kale_item.quantity.value).to eql("20")
    expect(potatoes_item.quantity.value).to eql("5")
  end

  context "delivery information" do
    context "for dropoff" do
      it "shows delivery address" do
        within("#address") do
          expect(page).to have_content("Delivery Address")
          expect(page).to have_content("Delivery on May 9, 2014 between 7:00AM and 11:00AM")
          expect(page).to have_content(market.addresses.first.address)
          expect(page).to have_content(market.addresses.first.city)
          expect(page).to have_content(market.addresses.first.state)
          expect(page).to have_content(market.addresses.first.zip)
        end
      end
    end

    context "for pickup" do
      let!(:delivery_schedule) { create(:delivery_schedule, :buyer_pickup,  market: market, day: 5) }

      it "shows pickup address" do
        within("#address") do
          expect(page).to have_content("Delivery Address")
          expect(page).to have_content("Pickup on May 9, 2014 between 10:00AM and 12:00PM")
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
      expect(cart_totals.delivery_fees).to have_content("$10.00")

      kale_item.set_quantity(98)
      bananas_item.quantity_field.click
      sleep(0.5)

      expect(cart_totals.delivery_fees).to have_content("$29.50")
    end

    context "when there are no delivery fees" do
      let!(:delivery_schedule) { create(:delivery_schedule, :fixed_fee, fee: 0, market: market, day: 5) }

      it "displays as 'Free!'" do
        expect(cart_totals.delivery_fees).to have_content("Free!")

        kale_item.set_quantity(98)
        bananas_item.quantity_field.click
        sleep(0.5)

        expect(cart_totals.delivery_fees).to have_content("Free!")
      end
    end
  end

  context "total" do
    it "is the subtotal plus delivery fees" do
      expect(cart_totals.total).to have_content("$50.00")

      kale_item.set_quantity(98)
      bananas_item.quantity_field.click
      sleep(0.5)

      expect(cart_totals.total).to have_content("$147.50")
    end
  end

  context "updating quantity" do
    it "updates the per-unit price based on the pricing tier it fits in" do
      expect(kale_item.price_for_quantity).to have_content("$1.00")

      kale_item.set_quantity(4)
      bananas_item.quantity_field.click
      expect(kale_item.price_for_quantity).to have_content("$2.50")

      kale_item.set_quantity(1)
      bananas_item.quantity_field.click
      expect(kale_item.price_for_quantity).to have_content("$3.00")

      kale_item.set_quantity(5)
      bananas_item.quantity_field.click
      expect(kale_item.price_for_quantity).to have_content("$2.50")

      kale_item.set_quantity(0)
      bananas_item.quantity_field.click
      expect(kale_item.price_for_quantity).to have_content("$3.00")
    end

    it "updates the overall price" do
      expect(kale_item.price).to have_content("$20.00")

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
      expect(cart_totals.subtotal).to have_content("$40.00")

      kale_item.set_quantity(98)
      bananas_item.quantity_field.click

      expect(cart_totals.subtotal).to have_content("$118.00")
    end
  end
end
