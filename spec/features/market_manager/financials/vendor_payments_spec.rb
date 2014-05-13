require "spec_helper"

feature "Payments to vendors" do
  let(:market) { create(:market, name: "Baskerville Co-op", po_payment_term: 14) }
  let!(:delivery_schedule) { create(:delivery_schedule, market: market, day: 3.days.ago.wday) }
  let!(:delivery) { Timecop.freeze(5.days.ago) { delivery_schedule.next_delivery } }
  let!(:market_manager) { create :user, managed_markets: [market] }

  let!(:seller1) { create(:organization, :seller, name: "Better Farms", markets: [market]) }
  let!(:seller2) { create(:organization, :seller, name: "Great Farms", markets: [market]) }
  let!(:seller3) { create(:organization, :seller, name: "Betterest Farms", markets: [market]) }
  let!(:seller4) { create(:organization, :seller, name: "Greater Farms", markets: [market]) }
  let!(:buyer)  { create(:organization, :buyer, name: "Money Bags", markets: [market]) }

  let!(:product1) { create(:product, :sellable, organization: seller1) }
  let!(:product2) { create(:product, :sellable, organization: seller2) }
  let!(:product3) { create(:product, :sellable, organization: seller2) }
  let!(:product4) { create(:product, :sellable, organization: seller3) }

  let!(:order1) { create(:order, items:[create(:order_item, :delivered, product: product1, quantity: 4)], market: market, organization: buyer, delivery: delivery, payment_method: "purchase order", order_number: "LO-001", total_cost: 27.96, placed_at: 19.days.ago) }
  let!(:order2) { create(:order, items:[create(:order_item, :delivered, product: product2, quantity: 3), create(:order_item, :delivered, product: product4, quantity: 7)], market: market, organization: buyer, delivery: delivery, payment_method: "purchase order", order_number: "LO-002", total_cost: 69.90, placed_at: 6.days.ago, payment_status: "paid") }
  let!(:order3) { create(:order, items:[create(:order_item, :delivered, product: product3, quantity: 6)], market: market, organization: buyer, delivery: delivery, payment_method: "purchase order", order_number: "LO-003", total_cost: 41.94, placed_at: 4.days.ago) }
  let!(:order4) { create(:order, items:[create(:order_item, :delivered, product: product2, quantity: 9), create(:order_item, :delivered, product: product3, quantity: 14)], market: market, organization: buyer, delivery: delivery, payment_method: "purchase order", order_number: "LO-004", total_cost: 160.77, placed_at: 3.days.ago) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as market_manager
    visit admin_financials_vendor_payments_path
  end

  scenario "displays the correct items" do
    seller_rows = Dom::Admin::Financials::VendorPaymentRow.all

    expect(seller_rows.size).to eq(3)
    expect(seller_rows[0].name).to have_content("Better Farms")
    expect(seller_rows[0].order_count).to have_content(/\A1 order from Baskerville Co-op Review/)
    expect(seller_rows[0].owed).to have_content("$27.96")

    expect(seller_rows[1].name).to have_content("Betterest Farms")
    expect(seller_rows[1].order_count).to have_content(/\A1 order from Baskerville Co-op Review/)
    expect(seller_rows[1].owed).to have_content("$48.93")

    expect(seller_rows[2].name).to have_content("Great Farms")
    expect(seller_rows[2].order_count).to have_content(/\A3 orders from Baskerville Co-op Review/)
    expect(seller_rows[2].owed).to have_content("$223.68")
  end

  scenario "de-selecting orders", :js do
    seller_row = Dom::Admin::Financials::VendorPaymentRow.for_seller("Great Farms")
    seller_row.review

    orders = Dom::Admin::Financials::VendorPaymentOrderRow.all

    expect(orders.size).to eq(3)
    expect(orders[0].order_number).to eq('LO-002')
    expect(orders[0].placed_at).to have_content(order2.placed_at.strftime("%b %d, %Y"))
    expect(orders[0].total).to have_content('$20.97')

    expect(orders[1].order_number).to eq('LO-003')
    expect(orders[1].placed_at).to have_content(order3.placed_at.strftime("%b %d, %Y"))
    expect(orders[1].total).to have_content('$41.94')

    expect(orders[2].order_number).to eq('LO-004')
    expect(orders[2].placed_at).to have_content(order4.placed_at.strftime("%b %d, %Y"))
    expect(orders[2].total).to have_content('$160.77')

    expect(seller_row.selected_owed).to have_content("$223.68")

    orders[1].click_check

    expect(seller_row.selected_owed).to have_content("$181.74")
  end

  scenario "mark all orders for seller paid", :js do
    seller_row = Dom::Admin::Financials::VendorPaymentRow.for_seller("Great Farms")
    seller_row.pay_all_now

    choose "Check"
    fill_in "Check #", with: "4234"

    within('.record-payment') do
      find_button("Record Payment").trigger('click')
    end

    expect(page).to have_content("Payment of $223.68 recorded for Great Farms")

    # Great Farms should no longer be in the payments list
    seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
    expect(seller_rows.map {|r| r.name.text }).to eq(["Better Farms", "Betterest Farms"])
  end

  scenario "mark selected orders for seller paid", :js do
    seller_row = Dom::Admin::Financials::VendorPaymentRow.for_seller("Great Farms")
    seller_row.review

    orders = Dom::Admin::Financials::VendorPaymentOrderRow.all
    orders[1].click_check

    seller_row.pay_selected

    choose "Check"
    fill_in "Check #", with: "4234"

    within('.record-payment') do
      click_button "Record Payment"
    end

    expect(page).to have_content("Payment of $181.74 recorded for Great Farms")

    # Great Farms should still be in the payments list
    seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
    expect(seller_rows.map {|r| r.name.text }).to eq(["Better Farms", "Betterest Farms", "Great Farms"])

    # With 1 order
    expect(seller_rows[2].name).to have_content("Great Farms")
    expect(seller_rows[2].order_count).to have_content(/\A1 order from Baskerville Co-op Review/)
    expect(seller_rows[2].owed).to have_content("$41.94")
  end
end
