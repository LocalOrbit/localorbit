require "spec_helper"

describe "Order summary" do
  let!(:market)  { create(:market, :with_addresses) }
  let!(:sellers) { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:others) { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:sellers_product1) { create(:product, :sellable, organization: sellers) }
  let!(:sellers_product2) { create(:product, :sellable, organization: sellers) }
  let!(:sellers_product3) { create(:product, :sellable, organization: sellers) }
  let!(:others_product) { create(:product, :sellable, organization: others) }

  let!(:buyer1) { create(:organization, :buyer, :single_location, markets: [market]) }
  let!(:buyer2) { create(:organization, :buyer, :single_location, markets: [market]) }

  let!(:friday_schedule_schedule) { create(:delivery_schedule, :buyer_pickup, market: market, day: 5) }
  let!(:friday_delivery) { create(:delivery, delivery_schedule: friday_schedule_schedule, deliver_on: Date.parse("May 9, 2014"), cutoff_time: Date.parse("May 8, 2014"))}

  let!(:sellers_order1)      { create(:order, organization: buyer1, market: market, delivery: friday_delivery) }
  let!(:sellers_order1_item1) { create(:order_item, order: sellers_order1, product: sellers_product1, quantity: 3)}
  let!(:sellers_order1_item2) { create(:order_item, order: sellers_order1, product: sellers_product3, quantity: 9)}

  let!(:sellers_order2)      { create(:order, organization: buyer2, market: market, delivery: friday_delivery) }
  let!(:sellers_order2_item) { create(:order_item, order: sellers_order2, product: sellers_product2, quantity: 6)}

  let!(:others_order)      { create(:order, organization: buyer2, market: market, delivery: friday_delivery) }
  let!(:others_order_item) { create(:order_item, order: others_order, product: others_product, quantity: 2)}

  before do
    Timecop.travel("May 5, 2014")
  end

  after do
    Timecop.return
  end

  context "as a seller" do
    let!(:user) { create(:user, organizations: [sellers]) }

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      visit admin_delivery_tools_order_summary_path(friday_delivery.id)
    end

    it "displays an order summary for the delivery" do
      expect(page).to have_content("Order Summary")
      expect(page).to have_content(sellers.name)
      expect(page).to have_content(sellers.shipping_location.address)
      expect(page).to have_content(sellers.shipping_location.phone)

      expect(page).to have_content(buyer1.name)
      expect(page).to have_content(sellers_order1.order_number)
      expect(page).to have_content(sellers_order1_item1.name)
      expect(page).to have_content(sellers_order1_item2.name)

      expect(page).to have_content(buyer2.name)
      expect(page).to have_content(sellers_order2.order_number)
      expect(page).to have_content(sellers_order2_item.name)
    end
  end
end
