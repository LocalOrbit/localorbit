require 'spec_helper'

feature "Viewing orders" do
  let!(:market) { create(:market)}
  let!(:seller) { create(:organization, :seller) }
  let!(:user) { create(:user, organizations: [seller]) }
  let!(:order1) { create(:order, organization: seller, market: market) }
  let!(:order2) { create(:order, organization: seller, market: market) }

  before do
    sign_in_as(user)
  end

  scenario "list of orders" do
    visit admin_financials_orders_path

    orders = Dom::Admin::OrderRow.all
    expect(orders.count).to eq(2)

    order = Dom::Admin::OrderRow.find_by_order_number(order1.order_number)
    expect(order.amount_owed).to eq("$#{order1.total_cost}")
    expect(order.delivery_status).to eq(order1.delivery_status)
    expect(order.buyer_status).to eq(order1.payment_status)
  end
end
