require 'spec_helper'

feature "Buyer Financial Overview" do
  let!(:market)  { create(:market, po_payment_term: 20, timezone: "Eastern Time (US & Canada)") }
  let!(:delivery_schedule) { create(:delivery_schedule) }
  let!(:delivery)    { delivery_schedule.next_delivery }

  let!(:seller)  { create(:organization, markets: [market]) }
  let!(:seller2) { create(:organization, markets: [market]) }
  let!(:buyer) { create(:organization, :single_location, markets: [market], can_sell: false) }

  let!(:user)    { create(:user, organizations: [buyer]) }

  let!(:kale) { create(:product, :sellable, organization: seller, name: "Kale") }
  let!(:peas) { create(:product, :sellable, organization: seller, name: "Peas") }
  let!(:from_different_seller) { create(:product, :sellable, organization: seller2, name: "Apples") }

  before do
    # Overdue Order
    Time.zone = "Eastern Time (US & Canada)"
    Timecop.travel(Time.current - 27.days) do

      order_item = create(:order_item, unit_price: 53.99, quantity: 1)
      @overdue_order1 = create(:order, delivery: delivery, items: [order_item], payment_method: "purchase order", market: market, organization: buyer)

      @overdue_order1.invoice
      deliver_order(@overdue_order1)
      @overdue_order1.save!

      order_item = create(:order_item, unit_price: 102.99, quantity: 1)
      @overdue_order2 = create(:order, delivery: delivery, items: [order_item], payment_method: "purchase order", market: market, organization: buyer)

      @overdue_order2.invoice
      deliver_order(@overdue_order2)
      @overdue_order2.save!
    end

    Timecop.travel(Time.current - 7.days) do
      order_item = create(:order_item, unit_price: 6.41, quantity: 2)
      @due_order = create(:order, delivery: delivery, items: [order_item], payment_method: "purchase order", market: market, organization: buyer)

      @due_order.invoice
      deliver_order(@due_order)
    end

    Timecop.travel(Time.current - 6.days) do
      order_item = create(:order_item, unit_price: 41.11, quantity: 2)
      @to_be_paid = create(:order, delivery: delivery, items: [order_item], payment_method: "purchase order", market: market, organization: buyer)

      @to_be_paid.invoice
      deliver_order(@to_be_paid)
    end

    Timecop.travel(Time.current - 6.days) do
      order_item = create(:order_item, unit_price: 46.43, quantity: 2)
      @uninvoiced1 = create(:order, delivery: delivery, items: [order_item], payment_method: "purchase order", market: market, organization: buyer)

      deliver_order(@uninvoiced1)
      #pay_order(@uninvoiced1)
    end

    Timecop.travel(Time.current - 6.days) do
      order_item = create(:order_item, unit_price: 150.01, quantity: 2)
      @uninvoiced2 = create(:order, delivery: delivery, items: [order_item], payment_method: "purchase order", market: market, organization: buyer)

      deliver_order(@uninvoiced2)
      #pay_order(@uninvoiced2)
    end
  end

  scenario "Buyer's default financial view is the overview" do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
    click_link "Dashboard", match: :first
    click_link "Financials"

    expect(page).to have_content("Payments Due")
    expect(page).to have_content("This is a snapshot")

    expect(money_out_row("Overdue").amount).to eql("$156.98")
    expect(money_out_row("Due").amount).to eql("$95.04")
    expect(money_out_row("Purchase Orders").amount).to eql("$392.88")

    click_link "Overdue"

    expect(page).to have_content(@overdue_order1.order_number)
    expect(page).to have_content(@overdue_order2.order_number)
    expect(page).not_to have_content(@due_order.order_number)
    expect(page).not_to have_content(@uninvoiced1.order_number)
    expect(page).not_to have_content(@uninvoiced2.order_number)

    within("#payment_status") do
      expect(find('option[selected]').text).to eql("Overdue")
    end

    click_link "Dashboard", match: :first
    click_link "Financials"
    click_link "Due"

    fill_in "q_invoice_due_date_date_lteq", with: 30.days.from_now.to_date.to_s
    click_button "Filter"

    expect(page).to have_content(@due_order.order_number)
    expect(page).not_to have_content(@overdue_order1.order_number)
    expect(page).not_to have_content(@overdue_order2.order_number)
    expect(page).not_to have_content(@uninvoiced1.order_number)
    expect(page).not_to have_content(@uninvoiced2.order_number)

    within("#payment_status") do
      expect(find('option[selected]').text).to eql("Due")
    end

    click_link "Dashboard", match: :first
    click_link "Financials"
    click_link "Purchase Orders"

    expect(page).not_to have_content(@due_order.order_number)
    expect(page).not_to have_content(@overdue_order1.order_number)
    expect(page).not_to have_content(@overdue_order2.order_number)
    expect(page).to have_content(@uninvoiced1.order_number)
    expect(page).to have_content(@uninvoiced2.order_number)
  end

  scenario "Buyer's 'due' items update when invoices get marked as paid" do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
    click_link "Dashboard", match: :first
    click_link "Financials"

    expect(money_out_row("Due").amount).to eql("$95.04")
    pay_order(@to_be_paid)

    click_link "Dashboard", match: :first
    click_link "Financials"

    expect(money_out_row("Due").amount).to eql("$12.82")
  end
end
