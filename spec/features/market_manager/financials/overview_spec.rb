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
    Time.zone = "Eastern Time (US & Canada)"

    # Order for a different market
    Timecop.travel(Time.current - 32.days) do
      order = create(:order, payment_method: "purchase order", market: market2, items:[
        create(:order_item, quantity: 5, product: peas, local_orbit_market_fee: 20.00),
        create(:order_item, quantity: 7, product: kale),
        create(:order_item, quantity: 7, product: from_different_seller)
      ])

      deliver_order(order)
      order.invoice
      order.save!
    end

    # Overdue Order
    # Total for market: (5+7+7)*6.99 = 132.81
    Timecop.travel(Time.current - 32.days) do
      order = create(:order, payment_method: "purchase order", market: market, items:[
        create(:order_item, quantity: 5, product: peas, market_seller_fee: 2.00, payment_seller_fee: 1.00),
        create(:order_item, quantity: 7, product: kale, market_seller_fee: 9.00, local_orbit_seller_fee: 8.00, local_orbit_market_fee: 10.00),
        create(:order_item, quantity: 7, product: from_different_seller, market_seller_fee: 12, local_orbit_seller_fee: 10) # Not included in overdue total
      ])

      deliver_order(order)
      order.invoice
      order.save!
    end

    # Payments for "Today" calculation
    # Credit Card
    # 6.99 + 6.99 + 7*6.99 = 62.91
    # Money to Seller: (1*6.99 - 1.00) + (1*6.99 - 3.00) + 7*6.99 = 58.91
    Timecop.travel(Time.current - 7.days) do
      order = create(:order, payment_method: "credit card", market: market, items:[
        create(:order_item, quantity: 1, product: peas, payment_seller_fee: 1.00, local_orbit_market_fee: 22.00),
        create(:order_item, quantity: 1, product: kale, market_seller_fee: 3.00),
        create(:order_item, quantity: 7, product: from_different_seller)
      ])

      deliver_order(order)
      pay_order(order)
    end

    # Payments for "Today" calculation
    # Purchase order
    # (3 + 7+ 7)*6.99 = 118.83
    # Money to Seller: 118.83 - 26 = 92.83
    paid_po = nil
    Timecop.travel(Time.current - 30.days) do
      paid_po = create(:order, payment_method: "purchase order", market: market, items:[
        create(:order_item, quantity: 3, product: peas, payment_seller_fee: 1.00, local_orbit_market_fee: 22.00),
        create(:order_item, quantity: 7, product: kale, market_seller_fee: 3.00),
        create(:order_item, quantity: 7, product: from_different_seller)
      ])

      deliver_order(paid_po)

      paid_po.invoice
      paid_po.save!
    end

    pay_order(paid_po)

    # ACH
    # 2*6.99 + 2*6.99 + 7*6.99 = 76.89
    # Money owed to seller = seller
    # Money to Seller: (2*6.99 - 1.00) + (2*6.99 - 2.00) + 7*6.99 = 73.89
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
    # Money to Seller: (3*6.99 - 20.00 - 1.00) + (10*6.99 - 1.00) + 7*6.99 = 117.80
    #
    Timecop.travel(Time.current - 28) do
      order = create(:order, payment_method: "purchase order", market: market, items:[
        create(:order_item, quantity: 3, product: peas, market_seller_fee: 20.00, local_orbit_seller_fee: 1.00),
        create(:order_item, quantity: 10, product: kale, local_orbit_seller_fee: 1.00),
        create(:order_item, quantity: 7, product: from_different_seller)
      ])

      deliver_order(order)
      order.invoice
      order.save!
    end

    # Payments for the next 7 days
    # (10+9+7)*6.99 = 181.74
    #
    # Money to Seller: (10*6.99 - 12.00) + (9*6.99 - 9.00) + 7*6.99 = 160.74
    Timecop.travel(Time.current - 2.days) do
      order = create(:order, payment_method: "credit card", market: market, items:[
        create(:order_item, quantity: 10, product: peas, local_orbit_seller_fee: 12.00),
        create(:order_item, quantity: 9, product: kale, market_seller_fee: 9),
        create(:order_item, quantity: 7, product: from_different_seller) # Not included in overdue total
      ])

      deliver_order(order)
      pay_order(order)
    end

    # (66+92+7)*6.99 = 1153.35
    # 1149.35
    Timecop.travel(Time.current - 23.days) do
      order = create(:order, payment_method: "purchase order", market: market, items:[
        create(:order_item, quantity: 66, product: peas, local_orbit_seller_fee: 1.00, local_orbit_market_fee: 9.00),
        create(:order_item, quantity: 92, product: kale, market_seller_fee: 3.00, local_orbit_market_fee: 12.00),
        create(:order_item, quantity: 7, product: from_different_seller) # Not included in overdue total
      ])

      deliver_order(order)
      order.invoice
      order.save!
    end

    # (20 + 9 + 7)*6.99 = 251.64
    Timecop.travel(Time.current - 29.days) do
      order = create(:order, payment_method: "purchase order", market: market, items:[
        create(:order_item, quantity: 20, product: peas, local_orbit_seller_fee: 1.00, local_orbit_market_fee: 9.00),
        create(:order_item, quantity: 9, product: kale, market_seller_fee: 3.00, local_orbit_market_fee: 12.00),
        create(:order_item, quantity: 7, product: from_different_seller) # Not included in overdue total
      ])

      deliver_order(order)
      order.invoice
      order.save!
    end

    # Uninvoiced Purchase Orders
    # (4*3)*6.99 = 83.88
    order = create(:order, payment_method: "purchase order", market: market, items:[
      create(:order_item, quantity: 4, product: peas, local_orbit_seller_fee: 1.00, local_orbit_market_fee: 9.00),
      create(:order_item, quantity: 4, product: kale, market_seller_fee: 3.00, local_orbit_market_fee: 12.00),
      create(:order_item, quantity: 4, product: from_different_seller) # Not included in overdue total
    ])

    deliver_order(order)
    order.save!

    # Uninvoiced Purchase Orders
    # (2*3)*6.99 = 41.94
    order = create(:order, payment_method: "purchase order", market: market, items:[
      create(:order_item, quantity: 2, product: peas, local_orbit_seller_fee: 1.00, local_orbit_market_fee: 9.00),
      create(:order_item, quantity: 2, product: kale, market_seller_fee: 3.00, local_orbit_market_fee: 12.00),
      create(:order_item, quantity: 2, product: from_different_seller) # Not included in overdue total
    ])


    deliver_order(order)
    order.save!
  end

  scenario "Market manager checks their financial overview" do
    switch_to_subdomain(market.subdomain)
    sign_in_as(market_manager)
    click_link "Financials"

    expect(money_in_row("Overdue").amount).to eql("$132.81")
    expect(money_in_row("Today").amount).to eql("$118.83")
    expect(money_in_row("Next 7 Days").amount).to eql("$1,404.99")
    expect(money_in_row("Next 30 Days").amount).to eql("$1,544.79")
    expect(money_in_row("Purchase Orders").amount).to eql("$125.82")
    expect(money_out_row("Next 7 Days").amount).to eql("$114.83")

    expect(Dom::Admin::Financials::MoneyOut.all[1].amount).to eql("$22.00")
  end

  scenario "Market manager navigates to their financial overview" do
    switch_to_subdomain(market.subdomain)
    sign_in_as(market_manager)
    click_link "Financials"

    expect(page).to have_content("Money In")
    expect(page).to have_content("Money Out")
    expect(page).to have_content("This is a snapshot")

    within(".money-in") do
      click_link "Send Invoices"
    end

    expect(page).to have_content("Unsent Invoices")

    click_link "Financials"

    within(".money-out") do
      click_link "Record Payments"
    end

    expect(page).to have_content("Coming Soon")
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
    expect(page).to have_content("This is a snapshot")
  end
end
