require "spec_helper"

feature "entering receipts" do
  let(:market) { create(:market, subdomain: "betterest", po_payment_term: 14) }
  let!(:delivery_schedule) { create(:delivery_schedule) }
  let!(:delivery)    { delivery_schedule.next_delivery }

  let!(:market_manager) { create :user, :market_manager, managed_markets: [market] }

  let!(:buyer_user) { create :user }

  let!(:seller) { create(:organization, :seller, name: "Better Farms", markets: [market]) }
  let!(:buyer)  { create(:organization, :buyer, name: "Money Bags", markets: [market], users: [buyer_user]) }

  let!(:product) { create(:product, :sellable, organization: seller) }

  let!(:order1) { create(:order, delivery: delivery, items: [create(:order_item, product: product, unit_price: 210.00)], market: market, organization: buyer, total_cost: 210.00, payment_method: "purchase order", order_number: "LO-001", placed_at: 19.days.ago, invoiced_at: 18.days.ago, invoice_due_date: 4.days.ago) }
  let!(:order2) { create(:order, delivery: delivery, items: [create(:order_item, product: product)], market: market, organization: buyer, total_cost: 6.99, payment_method: "purchase order", order_number: "LO-002", invoiced_at: 4.day.ago, invoice_due_date: 10.days.from_now, payment_status: "paid") }
  let!(:order3) { create(:order, delivery: delivery, items: [create(:order_item, product: product, unit_price: 420.00)], market: market, organization: buyer, total_cost: 420, payment_method: "purchase order", order_number: "LO-003", placed_at: 2.days.ago, invoiced_at: 2.day.ago, invoice_due_date: 12.days.from_now) }
  let!(:order4) { create(:order, delivery: delivery, items: [create(:order_item, product: product, unit_price: 840.00)], market: market, organization: buyer, total_cost: 420, payment_method: "purchase order", placed_at: 15.days.ago, invoiced_at: 12.day.ago, invoice_due_date: 2.days.ago) }
  let!(:order5) { create(:order, delivery: delivery, items: [create(:order_item, product: product, unit_price: 1680.00)], market: market, organization: buyer, total_cost: 420, payment_method: "purchase order", placed_at: 15.days.ago, invoiced_at: 12.day.ago, invoice_due_date: 2.days.ago) }

  invoice_auth_matcher = lambda do|r1, r2|
    matcher = %r{/admin/invoices/[0-9]+/invoice\.pdf\?auth_token=}
    matcher.match(r1.uri) && matcher.match(r2.uri)
  end

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as market_manager
    visit admin_financials_receipts_path
  end

  it "shows a list of unpaid invoices" do
    rows = Dom::Admin::Financials::InvoiceRow.all

    expect(rows.size).to eq(4)

    row = rows[0]
    expect(row.order_number).to eq("#{order1.order_number} PDF")
    expect(row.buyer).to eq("Money Bags")
    expect(row.order_date).to eq(19.days.ago.strftime("%m/%d/%Y"))
    expect(row.due_date).to eq("4 Days Overdue")
    expect(row.amount).to eq("$210.00")
    delivery = order1.delivery
    expect(row.text).to include(delivery.buyer_deliver_on.strftime("%m/%d/%Y") || delivery.deliver_on.strftime("%m/%d/%Y"))

    row = rows[1]
    expect(row.order_number).to eq("#{order4.order_number} PDF")
    expect(row.buyer).to eq("Money Bags")
    expect(row.order_date).to eq(15.days.ago.strftime("%m/%d/%Y"))
    expect(row.due_date).to eq("2 Days Overdue")
    expect(row.amount).to eq("$420.00")
    delivery = order2.delivery
    expect(row.text).to include(delivery.buyer_deliver_on.strftime("%m/%d/%Y") || delivery.deliver_on.strftime("%m/%d/%Y"))
  end

  context "after a seller has been deleted by the market manager" do
    it "keeps the seller entries in the list" do
      delete_organization(buyer)
      delete_organization(seller)

      visit admin_financials_receipts_path
      rows = Dom::Admin::Financials::InvoiceRow.all

      expect(rows.size).to eq(4)

      row = rows[0]
      expect(row.order_number).to eq("#{order1.order_number} PDF")
      expect(row.buyer).to eq("Money Bags")
      expect(row.order_date).to eq(19.days.ago.strftime("%m/%d/%Y"))
      expect(row.due_date).to eq("4 Days Overdue")
      expect(row.amount).to eq("$210.00")

      row = rows[1]
      expect(row.order_number).to eq("#{order4.order_number} PDF")
      expect(row.buyer).to eq("Money Bags")
      expect(row.order_date).to eq(15.days.ago.strftime("%m/%d/%Y"))
      expect(row.due_date).to eq("2 Days Overdue")
      expect(row.amount).to eq("$420.00")
    end
  end

  it "allows the user to enter payment of an invoice" do
    Dom::Admin::Financials::InvoiceRow.first.enter_receipt

    select "Check", from: "Payment Method"
    fill_in "Note", with: "4321"

    click_button "Enter Receipt"

    expect(page).to have_content("Payment recorded for order #{order1.order_number}")

    row = Dom::Admin::Financials::InvoiceRow.first
    expect(row.order_number).to eq("#{order4.order_number} PDF")
    expect(row.buyer).to eq("Money Bags")
    expect(row.order_date).to eq(15.days.ago.strftime("%m/%d/%Y"))
    expect(row.due_date).to eq("2 Days Overdue")
    expect(row.amount).to eq("$420.00")
  end

  it "allows the user to resend the invoice", vcr: {match_requests_on: [:host, invoice_auth_matcher]} do
    Dom::Admin::Financials::InvoiceRow.first.resend_invoice

    expect(page).to have_content("Invoice resent for order number #{order1.order_number}")
  end

  # it "allows the user to resend all overdue invoices", vcr: {match_requests_on: [:host, invoice_auth_matcher]} do
  #   click_link "Resend Overdue Invoices"
  #
  #   expect(page).to have_content("Invoice resent for order numbers #{order1.order_number}, #{order4.order_number}, #{order5.order_number}")
  # end

  context "filtering" do
    it "by order number" do
      expect(page).to have_content(order1.order_number)
      expect(page).to have_content(order3.order_number)

      fill_in "q_order_number_or_payment_note_cont", with: order1.order_number
      click_button "Filter"

      expect(page).to have_content(order1.order_number)
      expect(page).not_to have_content(order3.order_number)
    end
  end
end
