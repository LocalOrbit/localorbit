require "spec_helper"

context "when seller manages one organization" do
end

context "when seller manages more than one organization" do
end

feature "seller views their dashboard" do
  let!(:market) { create(:market) }
  let!(:organization) { create(:organization, :seller, markets: [market]) }
  let!(:user) { create(:user, organizations: [organization]) }
  let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
  let!(:delivery) { create(:delivery, delivery_schedule: delivery_schedule, deliver_on: DateTime.parse("2014-04-14 12:00:00")) }
  let!(:order) do create(:order,
                          delivery: delivery,
                          market: market,
                          placed_at: DateTime.parse("2014-04-01 12:00:00"),
                          delivery_status: "Delivered",
                          payment_status: "Pending",
                          order_number: "First Order"
                        )
  end
  let!(:product) { create(:product,  organization: organization) }
  let!(:order_item) { create(:order_item, product: product, order: order) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as user
  end

  it "displays all pending orders" do
    paid_order = create(:order, market: market, payment_status: "Paid")
    extra_order = create(:order,
      market: market,
      placed_at: DateTime.parse("2014-03-31 12:00:00"),
      delivery_status: "Delivered",
      payment_status: "Pending",
      order_number: "Extra Order"
    )
    create(:order_item, product: product, order: paid_order)
    create(:order_item, product: product, order: extra_order)

    visit dashboard_path

    expect(page).to have_content("Pending")
    expect(Dom::Dashboard::OrderRow.all.count).to eq(2)

    first_row = Dom::Dashboard::OrderRow.first

    expect(first_row.order_number).to eq("First Order")
    expect(first_row.placed_on).to eq("4/1/2014")
    expect(first_row.delivery).to eq("Delivered")
    expect(first_row.total).to eq("$6.99")

    second_row = Dom::Dashboard::OrderRow.all.last

    expect(second_row.order_number).to eq("Extra Order")
    expect(second_row.placed_on).to eq("3/31/2014")
    expect(second_row.delivery).to eq("Delivered")
    expect(second_row.total).to eq("$6.99")
  end

  it "displays a list of upcoming deliveries with information" do
    visit dashboard_path

    expect(Dom::Dashboard::UpcomingDelivery.all.count).to eq(2)

    first_delivery = Dom::Dashboard::UpcomingDelivery.first

    expect(first_delivery.delivery_date).to eq("Deliveries for April 14, 2014 7:00am")
    expect(first_delivery.location).to eq("")
    expect(first_delivery.number_of_orders).to eq(2)

    last_delivery = Dom::Dashboard::UpcomingDelivery.all.last

    expect(first_delivery.delivery_date).to eq("Deliveries for April 15, 2014 7:00am")
    expect(first_delivery.location).to eq("")
    expect(first_delivery.number_of_orders).to eq(1)
  end
end