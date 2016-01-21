require "spec_helper"

context "when seller manages one organization" do
end

context "when seller manages more than one organization" do
end

feature "seller views their dashboard" do
  before do
    Timecop.freeze(DateTime.parse("2014-04-01 12:00:00"))
    switch_to_subdomain(market.subdomain)
    sign_in_as user
  end

  let!(:market) { create(:market, :with_addresses) }

  let!(:delivery_schedule) { create(:delivery_schedule, :buyer_pickup, market: market, day: 5, seller_delivery_start: "7:00 AM") }
  let!(:delivery) { delivery_schedule.next_delivery }

  let!(:delivery_schedule2) { create(:delivery_schedule) }
  let!(:delivery2)    { delivery_schedule2.next_delivery }

  let!(:organization) { create(:organization, :seller, markets: [market]) }
  let!(:user) { create(:user, organizations: [organization]) }

  let!(:product) { create(:product, :sellable, organization: organization) }
  let!(:order_item) { create(:order_item, product: product, delivery_status: "delivered") }
  let!(:order) do
    create(:order,
           items: [order_item],
           delivery: delivery,
           market: market,
           placed_at: DateTime.parse("2014-03-30 12:00:00"),
           order_number: "First Order"
                        )
  end

  let!(:extra_order) do
    create(:order,
           items: create_list(:order_item, 1, product: product, delivery_status: "pending"),
           market: market,
           delivery: delivery2,
           placed_at: DateTime.parse("2014-03-31 12:00:00"),
           order_number: "Extra Order"
          )
  end

  after do
    Timecop.return
  end

  xit "displays all recent orders" do
    visit dashboard_path

    expect(page).to have_content("Recent Orders")

    order_rows = Dom::Dashboard::OrderRow.all

    expect(order_rows.size).to eq(2)

    first_row = order_rows.first

    expect(first_row.order_number).to eq("Extra Order")
    expect(first_row.placed_on).to eq("3/31/2014")
    expect(first_row.delivery).to eq("Pending")
    expect(first_row.total).to eq("$6.99")

    second_row = order_rows.last

    expect(second_row.order_number).to eq("First Order")
    expect(second_row.placed_on).to eq("3/30/2014")
    expect(second_row.delivery).to eq("Delivered")
    expect(second_row.total).to eq("$6.99")
  end

  xit "displays a list of upcoming deliveries with information" do
    market.addresses.first.update_attributes(name: "Idea Market")
    create(:order_item, product: create(:product, :sellable, organization: organization), order: order, delivery_status: "pending")
    create(:order_item, product: product, order: extra_order, delivery_status: "pending")

    extra_order.delivery = create(:delivery_schedule, market: market, day: 6, seller_delivery_start: "8:00 AM").next_delivery
    extra_order.save!

    visit dashboard_path

    delivery_rows = Dom::UpcomingDelivery.all

    expect(delivery_rows.count).to eq(2)

    first_delivery = delivery_rows.first

    expect(first_delivery.upcoming_delivery_date).to eq("Deliveries for Friday April 4, 2014 7:00 AM")
    expect(first_delivery.location_name).to eq("Idea Market")
    expect(first_delivery.location).to eq("44 E. 8th St, Holland, MI 49423")

    last_delivery = delivery_rows.last

    expect(last_delivery.upcoming_delivery_date).to eq("Deliveries for Saturday April 5, 2014 8:00 AM")
    expect(last_delivery.location).to eq("Direct to customer")
  end
end
