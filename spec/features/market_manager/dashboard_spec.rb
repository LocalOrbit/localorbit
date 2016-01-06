require "spec_helper"

feature "a market manager viewing their dashboard" do
  let!(:user) { create(:user) }
  let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }
  let!(:market) { create(:market, :with_addresses, organizations: [buyer]) }
  let!(:market_manager) { create(:user, :market_manager, managed_markets: [market]) }

  let!(:delivery_schedule) { create(:delivery_schedule) }
  let!(:delivery)    { delivery_schedule.next_delivery }

  before do
    Timecop.travel("January 15, 2016") do
      order_item = create(:order_item, unit_price: 10, quantity: 1)
      order = create(:order, delivery: delivery, items: [order_item], payment_method: "purchase order", market: market, total_cost: 10)
      order.save!
    end

    Timecop.travel("January 13, 2016") do
      order_item = create(:order_item, unit_price: 10, quantity: 1)
      order = create(:order, delivery: delivery, items: [order_item], payment_method: "purchase order", market: market, total_cost: 10)
      order.save!
    end

    Timecop.travel("January 5, 2016") do
      order_item = create(:order_item, unit_price: 10, quantity: 1)
      order = create(:order, delivery: delivery, items: [order_item], payment_method: "purchase order", market: market, total_cost: 10)
      order.save!
    end
  end

  def login
    Timecop.travel("January 15, 2016")
    switch_to_subdomain(market.subdomain)
    sign_in_as(market_manager)
  end

  before do
    login
    visit dashboard_path
  end

  it "market_manager views dashboard - 7D" do
    page.execute_script('$("input[type=\'radio\']:checked").prop(\'checked\', false)')
    page.execute_script('$("#sc-interval1").prop("checked", true).click()')
    expect(page).to have_selector("#totalSalesAmount", text: '$20')
    expect(page).to have_selector("#totalOrderCount", text: '2')
    expect(page).to have_selector("#averageSalesAmount", text: '$10')
  end

  it "market_manager views dashboard - 1D" do
    page.execute_script('$("input[type=\'radio\']:checked").prop(\'checked\', false)')
    page.execute_script('$("#sc-interval0").prop("checked", true).click()')
    expect(page).to have_selector("#totalSalesAmount", text: '$10')
    expect(page).to have_selector("#totalOrderCount", text: '1')
    expect(page).to have_selector("#averageSalesAmount", text: '$10')
  end

  it "market_manager views dashboard - MTD" do
    page.execute_script('$("input[type=\'radio\']:checked").prop(\'checked\', false)')
    page.execute_script('$("#sc-interval2").prop("checked", true).click()')
    expect(page).to have_selector("#totalSalesAmount", text: '$30')
    expect(page).to have_selector("#totalOrderCount", text: '3')
    expect(page).to have_selector("#averageSalesAmount", text: '$10')
  end
end