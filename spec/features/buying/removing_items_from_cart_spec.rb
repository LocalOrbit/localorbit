require "spec_helper"

describe "Removing items", :js do
  let!(:user) { create(:user, :buyer) }
  let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }

  let!(:fulton_farms) { create(:organization, :seller, :single_location, name: "Fulton St. Farms") }
  let!(:ada_farms) { create(:organization, :seller, :single_location, name: "Ada Farms") }

  let(:market) { create(:market, :with_addresses, organizations: [buyer, fulton_farms, ada_farms]) }

  let(:delivery_schedule) { create(:delivery_schedule, :percent_fee,  market: market, day: 5) }
  let(:delivery_day) { DateTime.parse("May 9, 2014, 11:00:00") }
  let(:delivery) do
    create(:delivery,
           delivery_schedule: delivery_schedule,
           deliver_on: delivery_day,
           cutoff_time: delivery_day - delivery_schedule.order_cutoff.hours
    )
  end

  # Fulton St. Farms
  let!(:bananas) { create(:product, :sellable, name: "Bananas", organization: fulton_farms, delivery_schedules: [delivery_schedule]) }
  let!(:bananas_lot) { create(:lot, product: bananas, quantity: 100) }
  let!(:bananas_price_buyer_base) do
    create(:price, :past_price, market: market, product: bananas, min_quantity: 1, organization: buyer, sale_price: 0.50)
  end

  let!(:kale) { create(:product, :sellable, name: "Kale", organization: fulton_farms, delivery_schedules: [delivery_schedule]) }
  let!(:kale_lot) { kale.lots.first.update_attribute(:quantity, 100) }
  let!(:kale_price_tier1) do
    create(:price, :past_price, market: market, product: kale, min_quantity: 4, sale_price: 2.50)
  end

  let!(:kale_price_tier2) do
    create(:price, :past_price, market: market, product: kale, min_quantity: 6, sale_price: 1.00)
  end

  # Ada Farms
  let!(:potatoes) { create(:product, :sellable, name: "Potatoes", organization: ada_farms, delivery_schedules: [delivery_schedule]) }
  let!(:pototoes_lot) { create(:lot, product: potatoes, quantity: 100) }

  let!(:beans) { create(:product, :sellable, name: "Beans", organization: ada_farms, delivery_schedules: [delivery_schedule]) }

  let!(:cart) { create(:cart, market: market, organization: buyer, user: user, location: buyer.locations.first, delivery: delivery) }
  let!(:cart_bananas) { create(:cart_item, cart: cart, product: bananas, quantity: 10) }
  let!(:cart_potatoes) { create(:cart_item, cart: cart, product: potatoes, quantity: 5) }
  let!(:cart_kale) { create(:cart_item, cart: cart, product: kale, quantity: 20) }

  def bananas_item
    Dom::Cart::Item.find_by_name(/\ABananas/)
  end

  def cart_link
    Dom::CartLink.first
  end

  def kale_item_on_products
    Dom::ProductListing.find_by_name("Kale")
  end

  def kale_item_on_checkout
    Dom::Cart::Item.find_by_name(/\AKale/)
  end

  before do
    Timecop.travel("May 5, 2014")
  end

  after do
    Timecop.return
  end

  context "on the checkout view" do
    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)

      cart_link.node.click
      expect(page).to have_content("Your Order")
      expect(page).to have_content("Bananas")
      expect(page).to have_content("Kale")
      expect(page).to have_content("Potatoes")
      expect(cart_link.count).to have_content("3")
    end

    it "by clear the entire cart" do
      click_link "Cancel Order"
      page.driver.browser.switch_to.alert.accept

      expect(cart_link.count).to have_content("0")
    end

    it "by clicking an items delete link" do
      kale_item_on_checkout.remove_link.click

      expect(Dom::CartLink.first).to have_content("Removed from cart!")

      expect(cart_link.count).to have_content("2")
      expect(kale_item_on_checkout).to be_nil
    end
  end

  context "on products view" do
    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      go_to_order_page

      expect(page).to have_content("Bananas")
      expect(page).to have_content("Kale")
      expect(page).to have_content("Potatoes")
      expect(cart_link.count).to have_content("3")
    end

    context "when no cart item exists for the product" do
      before do
        CartItem.destroy_all
        go_to_order_page
      end

      it "does not show the remove link" do
        expect(kale_item_on_products).to_not have_css("a.icon-clear")
      end

      it "shows the remove link once a cart item exists" do
        kale_item_on_products.set_quantity(1)
        expect(Dom::CartLink.first).to have_content("Added to cart!")
        expect(Dom::CartLink.first).to_not have_content("Added to cart!")

        expect(kale_item_on_products.node).to have_css(".icon-clear")
      end
    end

    it "by clicking an items delete link" do
      kale_item_on_products.remove_link.click
      expect(Dom::CartLink.first).to have_content("Removed from cart!")
      expect(Dom::CartLink.first).to_not have_content("Removed from cart!")

      expect(kale_item_on_products.quantity_field.value).to eql('')
      expect(cart_link.count).to have_content("2")
    end

    it "by setting the quantity to 0" do
      skip 'Valid test, need to fix regression from alt_order_page'

      kale_item_on_products.set_quantity('0')
      expect(Dom::CartLink.first).to have_content("Removed from cart!")
      expect(Dom::CartLink.first).to_not have_content("Removed from cart!")

      expect(kale_item_on_products.quantity_field.value).to eq('')
      expect(cart_link.count).to have_content("2")
    end
  end
end
