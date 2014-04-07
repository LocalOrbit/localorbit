require 'spec_helper'

describe 'Buyer viewing dashboard' do
  let!(:user)   { create(:user) }
  let!(:buyer)  { create(:organization, :single_location, :buyer, users: [user]) }
  let!(:buyer2) { create(:organization, :single_location, :buyer) }

  let!(:fulton_farms) { create(:organization, :seller, :single_location, name: "Fulton St. Farms") }
  let!(:ada_farms)    { create(:organization, :seller, :single_location, name: "Ada Farms") }

  let(:market)            { create(:market, :with_addresses, organizations: [buyer, buyer2, fulton_farms, ada_farms]) }
  let(:delivery_schedule) { create(:delivery_schedule,  market: market) }

  # Fulton St. Farms
  let!(:bananas) { create(:product, :sellable, name: "Bananas", organization: fulton_farms) }
  let!(:kale)    { create(:product, :sellable, name: "Kale", organization: fulton_farms) }

  # Ada Farms
  let!(:potatoes) { create(:product, :sellable, name: "Potatoes", organization: ada_farms) }

  let!(:order1)      { create(:order, organization: buyer, placed_at: Time.parse('2014-04-02')) }
  let!(:order_item1) { create(:order_item, order: order1, product: bananas) }

  let!(:order2)      { create(:order, organization: buyer, placed_at: Time.parse('2014-04-03')) }
  let!(:order_item2) { create(:order_item, order: order2, product: kale) }

  let!(:order3)      { create(:order, organization: buyer, placed_at: Time.parse('2014-04-04')) }
  let!(:order_item3) { create(:order_item, order: order3, product: potatoes) }

  let!(:order4)      { create(:order, organization: buyer2, placed_at: Time.parse('2014-04-03')) }
  let!(:order_item4) { create(:order_item, order: order4, product: potatoes) }

  it 'shows their order history' do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)

    expect(page).not_to have_content("Purchase History")

    click_link 'Dashboard'

    expect(page).to have_content("Purchase History")

    orders = Dom::Dashboard::OrderRow.all
    expect(orders.size).to eq(3)

    order = orders[0]
    expect(order.order_number).to eq(order3.order_number)
    expect(order.order_date).to eq('04/04/2014')
    expect(order.delivery_status).to eq('Pending')
    expect(order.payment_status).to eq('Unpaid')
    expect(order.total).to eq("$#{order3.total_cost}")

    order = orders[1]
    expect(order.order_number).to eq(order2.order_number)
    expect(order.order_date).to eq('04/03/2014')
    expect(order.delivery_status).to eq('Pending')
    expect(order.payment_status).to eq('Unpaid')
    expect(order.total).to eq("$#{order3.total_cost}")

    order = orders[2]
    expect(order.order_number).to eq(order1.order_number)
    expect(order.order_date).to eq('04/02/2014')
    expect(order.delivery_status).to eq('Pending')
    expect(order.payment_status).to eq('Unpaid')
    expect(order.total).to eq("$#{order3.total_cost}")
  end
end
