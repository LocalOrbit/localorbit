require 'spec_helper'

feature "Buyer Financial Overview" do
  let!(:market)  { create(:market, po_payment_term: 30, timezone: "Eastern Time (US & Canada)") }
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
    Timecop.travel(Time.current - 32.days) do
      order = create(:order, :with_items, total_cost: 53.99, payment_method: "purchase order", market: market, organization: buyer)

      order.invoice
      deliver_order(order)
      order.save!

      order = create(:order, :with_items, total_cost: 102.99, payment_method: "purchase order", market: market, organization: buyer)

      order.invoice
      deliver_order(order)
      order.save!
    end

    Timecop.travel(Time.current - 7.days) do
      order = create(:order, :with_items, total_cost: 12.82, payment_method: "purchase order", market: market, organization: buyer)

      order.invoice
      deliver_order(order)
      pay_order(order)
    end

    Timecop.travel(Time.current - 6.days) do
      order = create(:order, :with_items, total_cost: 82.22, payment_method: "purchase order", market: market, organization: buyer)

      order.invoice
      deliver_order(order)
      pay_order(order)
    end

    Timecop.travel(Time.current - 6.days) do
      order = create(:order, :with_items, total_cost: 92.86, payment_method: "purchase order", market: market, organization: buyer)

      deliver_order(order)
      pay_order(order)
    end

    Timecop.travel(Time.current - 6.days) do
      order = create(:order, :with_items, total_cost: 300.02, payment_method: "purchase order", market: market, organization: buyer)

      deliver_order(order)
      pay_order(order)
    end
  end

  scenario "Buyer's default financial view is the overview" do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
    click_link "Dashboard"
    click_link "Financials"

    expect(page).to have_content("Payments Due")
    expect(page).to have_content("This is a snapshot")

    expect(money_out_row("Overdue").amount).to eql("$156.98")
    expect(money_out_row("Due").amount).to eql("$95.04")
    expect(money_out_row("Purchase Orders").amount).to eql("$392.88")
  end
end
