require "spec_helper"

describe "Buyer viewing dashboard" do
  let!(:user)   { create(:user) }

  let!(:buyer)  { create(:organization, :single_location, :buyer, users: [user]) }
  let!(:buyer2) { create(:organization, :single_location, :buyer) }

  let!(:fulton_farms) { create(:organization, :seller, :single_location, name: "Fulton St. Farms") }
  let!(:ada_farms)    { create(:organization, :seller, :single_location, name: "Ada Farms") }

  let(:market)            { create(:market, :with_addresses, organizations: [buyer, buyer2, fulton_farms, ada_farms]) }
  let!(:delivery_schedule) { create(:delivery_schedule) }
  let!(:delivery)    { delivery_schedule.next_delivery }

  # Fulton St. Farms
  let!(:bananas) { create(:product, :sellable, name: "Bananas", organization: fulton_farms) }
  let!(:kale)    { create(:product, :sellable, name: "Kale", organization: fulton_farms) }

  # Ada Farms
  let!(:potatoes) { create(:product, :sellable, name: "Potatoes", organization: ada_farms) }

  context "with orders" do
    let!(:order_item1) { create(:order_item, product: bananas) }
    let!(:order1)      { create(:order, delivery: delivery, items: [order_item1], organization: buyer) }

    let!(:order_item2) { create(:order_item, product: kale) }
    let!(:order2)      { create(:order, delivery: delivery, items: [order_item2], organization: buyer) }

    let!(:order_item3) { create(:order_item, product: potatoes) }
    let!(:order3)      { create(:order, delivery: delivery, items: [order_item3], organization: buyer) }

    let!(:order_item4) { create(:order_item, product: potatoes) }
    let!(:order4)      { create(:order, delivery: delivery, items: [order_item4], organization: buyer2) }

    it "shows their order history" do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)

      expect(page).not_to have_css("h1", text: "Purchase History")

      click_link "Dashboard", match: :first

      expect(page).to have_css("h1", text: "Purchase History")

      orders = Dom::Dashboard::OrderRow.all
      expect(orders.size).to eq(3)

      order = orders[0]
      expect(order.order_number).to eq(order3.order_number)
      expect(order.order_date).to eq(Time.now.strftime("%m/%d/%Y"))
      expect(order.delivery_status).to eq("Pending")
      expect(order.payment_status).to eq("Unpaid")
      expect(order.total).to eq("$#{order3.total_cost}")

      order = orders[1]
      expect(order.order_number).to eq(order2.order_number)
      expect(order.order_date).to eq(Time.now.strftime("%m/%d/%Y"))
      expect(order.delivery_status).to eq("Pending")
      expect(order.payment_status).to eq("Unpaid")
      expect(order.total).to eq("$#{order3.total_cost}")

      order = orders[2]
      expect(order.order_number).to eq(order1.order_number)
      expect(order.order_date).to eq(Time.now.strftime("%m/%d/%Y"))
      expect(order.delivery_status).to eq("Pending")
      expect(order.payment_status).to eq("Unpaid")
      expect(order.total).to eq("$#{order3.total_cost}")
    end

    it "lets them open their Orders" do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      click_link "Dashboard", match: :first

      orders = Dom::Dashboard::OrderRow.all
      expect(orders.size).to eq(3)

      follow_buyer_order_link order_number: orders[0].order_number
    end

    context "when they're in multiple buying organizations" do
      let!(:buyer3)  { create(:organization, :single_location, :buyer, users: [user]) }

      it "lets them jump to Orders without selecting an Organization first" do
        buyer3.markets << market
        user.reload
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        click_link "Dashboard", match: :first

        orders = Dom::Dashboard::OrderRow.all
        expect(orders.size).to eq(3)

        follow_buyer_order_link order_number: orders[0].order_number
      end
    end
  end

  context "without orders" do
    it "shows an empty state for the order history table" do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      visit dashboard_path

      expect(page).to have_content("Purchase History")
      expect(page).to have_content("No Results")
    end
  end
end
