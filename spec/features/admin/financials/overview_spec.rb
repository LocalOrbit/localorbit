require "spec_helper"

feature "Seller Financial Overview" do
  let!(:market)  { create(:market, po_payment_term: 30, timezone: "Eastern Time (US & Canada)") }
  let!(:delivery_schedule) { create(:delivery_schedule) }
  let!(:delivery)    { delivery_schedule.next_delivery }
  let!(:seller)  { create(:organization, markets: [market]) }
  let!(:seller2) { create(:organization, markets: [market]) }

  let!(:user)    { create(:user, organizations: [seller]) }

  let!(:kale) { create(:product, :sellable, organization: seller, name: "Kale") }
  let!(:peas) { create(:product, :sellable, organization: seller, name: "Peas") }
  let!(:from_different_seller) { create(:product, :sellable, organization: seller2, name: "Apples") }

  before do
    # Overdue Order
    # Total for seller: (5*6.99) + (7*6.99) - 2.00 - 1.00 - 9.00 - 8.00 = 63.88
    Time.zone = "Eastern Time (US & Canada)"
    Timecop.travel(Time.current - 32.days) do
      order = create(:order, delivery: delivery, payment_method: "purchase order", market: market, items: [
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
    # 9.98
    Timecop.travel(Time.current - 7.days) do
      order = create(:order, delivery: delivery, payment_method: "credit card", market: market, items: [
        create(:order_item, quantity: 1, product: peas, payment_seller_fee: 1.00),
        create(:order_item, quantity: 1, product: kale, market_seller_fee: 3.00),
        create(:order_item, quantity: 7, product: from_different_seller) # Not included in overdue total
      ])

      deliver_order(order)
      pay_order(order)
    end

    # ACH
    # 24.96
    Timecop.travel(Time.current - 7.days) do
      order = create(:order, delivery: delivery, payment_method: "ach", market: market, items: [
        create(:order_item, quantity: 2, product: peas, payment_seller_fee: 1.00),
        create(:order_item, quantity: 2, product: kale, local_orbit_seller_fee: 2.00),
        create(:order_item, quantity: 7, product: from_different_seller) # Not included in overdue total
      ])

      deliver_order(order)
      pay_order(order)
    end

    # Purchase order
    # 68.87
    Timecop.travel(Time.current - 7.days) do
      order = create(:order, delivery: delivery, payment_method: "purchase order", market: market, items: [
        create(:order_item, quantity: 3, product: peas, market_seller_fee: 20.00, local_orbit_seller_fee: 1.00),
        create(:order_item, quantity: 10, product: kale, local_orbit_seller_fee: 1.00),
        create(:order_item, quantity: 7, product: from_different_seller) # Not included in overdue total
      ])

      deliver_order(order)
      pay_order(order)
    end

    # Payments for the next 7 days
    # (10 + 9)*6.99 - 12 - 9 = 10*6.99 + 9*6.99 = $111.81
    Timecop.travel(Time.current - 1.days) do
      order = create(:order, delivery: delivery, payment_method: "credit card", market: market, items: [
        create(:order_item, quantity: 10, product: peas, local_orbit_seller_fee: 12.00),
        create(:order_item, quantity: 9, product: kale, market_seller_fee: 9),
        create(:order_item, quantity: 7, product: from_different_seller) # Not included in overdue total
      ])

      deliver_order(order)
      pay_order(order)
    end

    # (66 + 92)*6.99 - 1.00 - 3.00 = $1100.42
    Timecop.travel(Time.current - 6.days) do
      order = create(:order, delivery: delivery, payment_method: "purchase order", market: market, items: [
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
    sign_in_as(user)
    click_link "Financials"

    # Sellers will not see the money-out section
    expect(Dom::Admin::Financials::MoneyOut.all).to be_empty

    expect(money_in_row("Overdue").amount).to eql("$63.88")
    expect(money_in_row("Due Today").amount).to eql("$103.81")
    expect(money_in_row("Due In Next 7 Days").amount).to eql("$1,212.23")
  end

  scenario "Seller navigates to their financial overview" do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
    click_link "Financials"

    expect(page).to have_content("Money In")
    expect(page).to have_content("This is a snapshot")

    expect(page).not_to have_content("Send Invoices")
    expect(page).not_to have_content("Record Payments")
  end

  def visit_financials
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
    visit "/admin/financials"
  end

  scenario "Seller navigates directly to their financial overview" do
    visit_financials
    expect(page).to have_content("Money In")
    expect(page).to have_content("This is a snapshot")
  end
end
