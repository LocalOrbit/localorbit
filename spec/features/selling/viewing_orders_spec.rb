require 'spec_helper'

feature "Viewing orders" do
  let!(:market)      { create(:market, market_seller_fee: 5, local_orbit_seller_fee: 4)}
  let!(:seller_org1) { create(:organization, :seller, markets: [market]) }
  let!(:seller_org2) { create(:organization, :seller, markets: [market]) }
  let!(:buyer_org)   { create(:organization, :buyer,  markets: [market]) }
  let!(:user)        { create(:user, organizations: [seller_org1]) }
  let!(:product1)    { create(:product, :sellable, organization: seller_org1) }
  let!(:product2)    { create(:product, :sellable, organization: seller_org2) }

  let!(:order_item1) { create(:order_item, product: product1, quantity: 2, unit_price: 4.99, market_seller_fee: 0.50, local_orbit_seller_fee: 0.40) }
  let!(:order_item2) { create(:order_item, product: product2, quantity: 2, unit_price: 8.99, market_seller_fee: 0.90, local_orbit_seller_fee: 0.72) }
  let!(:order1)      { create(:order, items: [order_item1, order_item2], organization: buyer_org, market: market, total_cost: 27.96) }

  let!(:order_item3) { create(:order_item, product: product1, quantity: 2, unit_price: 8.99, market_seller_fee: 0.90, local_orbit_seller_fee: 0.72) }
  let!(:order_item4) { create(:order_item, product: product2, quantity: 3, unit_price: 7.99, market_seller_fee: 1.20, local_orbit_seller_fee: 0.96) }
  let!(:order2)      { create(:order, items: [order_item3, order_item4], organization: buyer_org, market: market, total_cost: 41.95) }

  let!(:order_item5) { create(:order_item, product: product2) }
  let!(:order3)      { create(:order, items: [order_item5], organization: buyer_org, market: market) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  scenario "list of orders" do
    visit admin_orders_path

    orders = Dom::Admin::OrderRow.all
    expect(orders.count).to eq(2)

    order = Dom::Admin::OrderRow.find_by_order_number(order1.order_number)
    expect(order.amount_owed).to eq("$9.08")
    expect(order.delivery_status).to eq('Pending')
    expect(order.buyer_status).to eq('Unpaid')

    order = Dom::Admin::OrderRow.find_by_order_number(order2.order_number)
    expect(order.amount_owed).to eq("$16.36")
    expect(order.delivery_status).to eq('Pending')
    expect(order.buyer_status).to eq('Unpaid')
  end

  scenario "order details" do
    visit admin_orders_path

    click_link order1.order_number

    expect(page).to have_content("Order info")
    expect(page).to have_content(order1.organization.name)
    expect(page).to have_content("$9.98")
    expect(page).to have_content("Purchase Order")

    items = Dom::Order::ItemRow.all
    expect(items.count).to eq(1)

    item = Dom::Order::ItemRow.first
    expect(item.name).to eq(order_item1.name)
    expect(item.quantity).to eq(order_item1.quantity.to_s)
    expect(item.price).to eq("$#{order_item1.unit_price}")
    expect(item.discount).to eq('$0.00')
    expect(item.total).to eq("$9.98")
    expect(item.payment_status).to eq("Unpaid")

    summary = Dom::Admin::OrderSummaryRow.first
    expect(summary.gross_total).to eq("$9.98")
    expect(summary.discount).to eq("$0.00")
    expect(summary.transaction_fees).to eq("$0.90")
    expect(summary.payment_processing).to eq("$0.00")
    expect(summary.net_sale).to eq("$9.08")
    expect(summary.delivery_status).to eq("Pending")
    expect(summary.payment_status).to eq("Unpaid")
  end
end
