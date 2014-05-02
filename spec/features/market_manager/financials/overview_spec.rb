require 'spec_helper'

feature "Market Manager Financial Overview" do
  let!(:market_manager) { create(:user, :market_manager) }
  let!(:market)  { create(:market, po_payment_term: 30, timezone: "Eastern Time (US & Canada)", managers: [market_manager]) }
  let!(:market2)  { create(:market, po_payment_term: 30, timezone: "Eastern Time (US & Canada)") }

  let!(:seller)  { create(:organization, markets: [market]) }
  let!(:seller2) { create(:organization, markets: [market, market2]) }

  let!(:kale) { create(:product, :sellable, organization: seller, name: "Kale") }
  let!(:peas) { create(:product, :sellable, organization: seller, name: "Peas") }
  let!(:from_different_seller) { create(:product, :sellable, organization: seller2, name: "Apples") }

  def deliver_order(order)
    order.items.each do |item|
      item.delivery_status = "delivered"
      order.save!
    end
  end

  def pay_order(order)
    order.payment_status = "paid"
    order.save!
  end

  before do
    # Order for a different market
    Timecop.travel(Time.current - 32.days) do
      order = create(:order, payment_method: "purchase order", market: market2, items:[
        create(:order_item, quantity: 5, product: peas),
        create(:order_item, quantity: 7, product: kale),
        create(:order_item, quantity: 7, product: from_different_seller)
      ])

      order.invoice
      deliver_order(order)
      order.save!
    end

    # Overdue Order
    # Total for market: (5+7+7)*6.99 = 132.81
    Time.zone = "Eastern Time (US & Canada)"
    Timecop.travel(Time.current - 32.days) do
      order = create(:order, payment_method: "purchase order", market: market, items:[
        create(:order_item, quantity: 5, product: peas, market_seller_fee: 2.00, payment_seller_fee: 1.00),
        create(:order_item, quantity: 7, product: kale, market_seller_fee: 9.00, local_orbit_seller_fee: 8.00),
        create(:order_item, quantity: 7, product: from_different_seller, market_seller_fee: 12, local_orbit_seller_fee: 10) # Not included in overdue total
      ])

      order.invoice
      deliver_order(order)
      order.save!
    end

    # Payments for "Today" calculation
    # Credit Card
    # 6.99 + 6.99 + 7*6.99 = 62.91
    Timecop.travel(Time.current - 7.days) do
      order = create(:order, payment_method: "credit card", market: market, items:[
        create(:order_item, quantity: 1, product: peas, payment_seller_fee: 1.00),
        create(:order_item, quantity: 1, product: kale, market_seller_fee: 3.00),
        create(:order_item, quantity: 7, product: from_different_seller)
      ])

      deliver_order(order)
      pay_order(order)
    end

    # ACH
    # 2*6.99 + 2*6.99 + 7*6.99 = 76.89
    Timecop.travel(Time.current - 7.days) do
      order = create(:order, payment_method: "ach", market: market, items:[
        create(:order_item, quantity: 2, product: peas, payment_seller_fee: 1.00),
        create(:order_item, quantity: 2, product: kale, local_orbit_seller_fee: 2.00),
        create(:order_item, quantity: 7, product: from_different_seller)
      ])

      deliver_order(order)
      pay_order(order)
    end

    # Purchase order
    # (3 + 10 + 7)*6.99 = 139.8
    Timecop.travel(Time.current - 7.days) do
      order = create(:order, payment_method: "purchase order", market: market, items:[
        create(:order_item, quantity: 3, product: peas, market_seller_fee: 20.00, local_orbit_seller_fee: 1.00),
        create(:order_item, quantity: 10, product: kale, local_orbit_seller_fee: 1.00),
        create(:order_item, quantity: 7, product: from_different_seller)
      ])

      deliver_order(order)
      pay_order(order)
    end

    # Payments for the next 7 days
    # (10+9+7)*6.99 = 181.74
    Timecop.travel(Time.current - 1.days) do
      order = create(:order, payment_method: "credit card", market: market, items:[
        create(:order_item, quantity: 10, product: peas, local_orbit_seller_fee: 12.00),
        create(:order_item, quantity: 9, product: kale, market_seller_fee: 9),
        create(:order_item, quantity: 7, product: from_different_seller) # Not included in overdue total
      ])

      deliver_order(order)
      pay_order(order)
    end

    # (66+92+7)*6.99 = 1153.35
    Timecop.travel(Time.current - 6.days) do
      order = create(:order, payment_method: "purchase order", market: market, items:[
        create(:order_item, quantity: 66, product: peas, local_orbit_seller_fee: 1.00),
        create(:order_item, quantity: 92, product: kale, market_seller_fee: 3.00),
        create(:order_item, quantity: 7, product: from_different_seller) # Not included in overdue total
      ])

      deliver_order(order)
      pay_order(order)
    end
  end

  scenario "Seller checks their financial overview" do
    switch_to_subdomain(market.subdomain)
    sign_in_as(market_manager)
    click_link "Financials"

    expect(financial_row("Overdue").amount).to eql("$132.81")
    expect(financial_row("Today").amount).to eql("$279.60")
    expect(financial_row("Next 7 Days").amount).to eql("$1,335.09")
  end

  scenario "Seller navigates to their financial overview" do
    switch_to_subdomain(market.subdomain)
    sign_in_as(market_manager)
    click_link "Financials"

    expect(page).to have_content("Money In")
    expect(page).to have_content("This is a snapshot")
  end

  def visit_financials
    switch_to_subdomain(market.subdomain)
    sign_in_as(market_manager)
    visit "/admin/financials"
  end

  def financial_row(title)
    Dom::Admin::Financials::OverviewStat.find_by_title(title)
  end

  scenario "Seller navigates directly to their financial overview" do
    visit_financials
    expect(page).to have_content("Money In")
    expect(page).to have_content("This is a snapshot")
  end
end
