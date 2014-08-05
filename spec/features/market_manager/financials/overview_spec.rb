require 'spec_helper'

feature "Market Manager Financial Overview" do
  let!(:market_manager) { create(:user, :market_manager) }
  let!(:market)  { create(:market, po_payment_term: 30, timezone: "Eastern Time (US & Canada)", managers: [market_manager]) }
  let!(:market2)  { create(:market, po_payment_term: 30, timezone: "Eastern Time (US & Canada)") }
  let!(:delivery_schedule) { create(:delivery_schedule) }
  let!(:delivery)    { delivery_schedule.next_delivery }

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
    Time.zone = "Eastern Time (US & Canada)"

    # Order for a different market
    Timecop.travel(Time.current - 32.days) do
      order_item = create(:order_item, unit_price: 2.50, quantity: 2)
      order = create(:order, delivery: delivery, items: [order_item], payment_method: "purchase order", market: market2, total_cost: 5.00)

      deliver_order(order)
      order.invoice
      order.save!
    end

    # Overdue Order
    # Total for market: (5+7+7)*6.99 = 132.81
    Timecop.travel(Time.current - 32.days) do
      order_item = create(:order_item, unit_price: 6.00, quantity: 2)
      order = create(:order, delivery: delivery, items: [order_item], payment_method: "purchase order", market: market, total_cost: 12.00)

      deliver_order(order)
      order.invoice
      order.save!
    end

    # Payments for "Today" calculation
    # Purchase order
    # (3 + 7+ 7)*6.99 = 118.83
    # Money to Seller: 118.83 - 26 = 92.83
    paid_po = nil

    Timecop.travel(Time.current - 30.days) do
      paid_po = create(:order, delivery: delivery, payment_method: "purchase order", market: market, total_cost: 27.96, items:[
        create(:order_item, quantity: 1, unit_price: 27.96, product: peas, payment_seller_fee: 1.00, local_orbit_market_fee: 10.00)
      ])

      deliver_order(paid_po)

      paid_po.invoice
      paid_po.save!
    end

    pay_order(paid_po)

    # Orders for the Next 7
    # (3*6.99) - 99
    Timecop.travel(Time.current - 28.days) do
      order = create(:order, delivery: delivery, payment_method: "purchase order", market: market, total_cost: 20.97, items:[
        create(:order_item, quantity: 1, unit_price: 20.97, product: peas, payment_seller_fee: 1.00)
      ])

      deliver_order(order)
      order.invoice
      order.save!
    end

    Timecop.travel(Time.current - 23.days) do
      order = create(:order, delivery: delivery, payment_method: "purchase order", market: market, total_cost: 48.93, items:[
        create(:order_item, quantity: 1, unit_price: 48.93, product: peas, payment_seller_fee: 3)
      ])

      deliver_order(order)
      order.invoice
      order.save!
    end

    Timecop.travel(Time.current - 16.days) do
      order_item = create(:order_item, quantity: 1, unit_price: 302.77, product: peas, payment_seller_fee: 1)
      order = create(:order, delivery: delivery, items: [order_item], payment_method: "purchase order", market: market, total_cost: 302.77)

      deliver_order(order)
      order.invoice
      order.save!
    end

    # Uninvoiced Purchase Orders
    order_item = create(:order_item, unit_price: 12.99, quantity: 1)
    order = create(:order, delivery: delivery, items: [order_item], payment_method: "purchase order", market: market, total_cost: 12.99)
    deliver_order(order)
    order.save!

    order_item = create(:order_item, unit_price: 43.42, quantity: 2)
    order = create(:order, delivery: delivery, items: [order_item], payment_method: "purchase order", market: market, total_cost: 86.84)
    deliver_order(order)
    order.save!
  end

  scenario "Market manager checks their financial overview" do
    switch_to_subdomain(market.subdomain)
    sign_in_as(market_manager)
    click_link "Financials"

    expect(money_in_row("Overdue").amount).to eql("$12.00")
    expect(money_in_row("Today").amount).to eql("$27.96")
    expect(money_in_row("Next 7 Days").amount).to eql("$69.90")
    expect(money_in_row("Next 30 Days").amount).to eql("$302.77")
    expect(money_in_row("Purchase Orders").amount).to eql("$99.83")

    expect(money_out_row("Next 7 Days").amount).to eql("$26.96")
    expect(Dom::Admin::Financials::MoneyOut.all[1].amount).to eql("$10.00")
  end

  scenario "Market manager navigates to their financial overview" do
    switch_to_subdomain(market.subdomain)
    sign_in_as(market_manager)
    click_link "Financials"

    expect(page).to have_content("Money In")
    expect(page).to have_content("Money Out")
    expect(page).to have_content("This is a list of all money currently owed to your organization and that you owe to other organizations.")

    within(".money-in") do
      click_link "Send Invoices"
    end

    expect(page).to have_content("Unsent Invoices")

    click_link "Financials"

    within(".money-out") do
      click_link "Record Payments"
    end

    expect(page).to have_content("Record Payments to Vendors")
  end

  def visit_financials
    switch_to_subdomain(market.subdomain)
    sign_in_as(market_manager)
    visit "/admin/financials"
  end

  def money_in_row(title)
    Dom::Admin::Financials::MoneyIn.find_by_title(title)
  end

  def money_out_row(title)
    Dom::Admin::Financials::MoneyOut.find_by_title(title)
  end


  scenario "Market manager navigates directly to their financial overview" do
    visit_financials
    expect(page).to have_content("Money In")
    expect(page).to have_content("This is a list of all money currently owed to your organization and that you owe to other organizations.")

  end
end
