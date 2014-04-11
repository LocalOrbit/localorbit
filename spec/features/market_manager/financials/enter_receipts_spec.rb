require "spec_helper"

feature "entering receipts" do
  let(:market) { create(:market, po_payment_term: 14) }
  let!(:market_manager) { create :user, managed_markets: [market] }

  let!(:buyer_user) { create :user }

  let!(:seller) { create(:organization, :seller, name: "Better Farms", markets: [market]) }
  let!(:buyer)  { create(:organization, :buyer, name: "Money Bags", markets: [market], users: [buyer_user]) }

  let!(:product) { create(:product, :sellable, organization: seller) }

  let!(:order1) { create(:order, market: market, organization: buyer, payment_method: "purchase order", order_number: "LO-001", total_cost: 210, placed_at: 19.days.ago, invoiced_at: 18.days.ago, invoice_due_date: 4.days.ago) }
  let!(:order_item1) { create(:order_item, order: order1, product: product) }
  let!(:order2) { create(:order, market: market, organization: buyer, payment_method: "purchase order", order_number: "LO-002", invoiced_at: 4.day.ago, invoice_due_date: 10.days.from_now, payment_status: "paid") }
  let!(:order_item2) { create(:order_item, order: order2, product: product) }
  let!(:order3) { create(:order, market: market, organization: buyer, payment_method: "purchase order", order_number: "LO-003", total_cost: 420, placed_at: 2.days.ago, invoiced_at: 2.day.ago, invoice_due_date: 12.days.from_now) }
  let!(:order_item3) { create(:order_item, order: order3, product: product) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as market_manager
    visit admin_financials_receipts_path
  end

  it "shows a list of unpaid invoices" do
    rows = Dom::Admin::Financials::InvoiceRow.all

    expect(rows.size).to eq(2)

    row = rows[0]
    expect(row.order_number).to eq("LO-001")
    expect(row.buyer).to eq("Money Bags")
    expect(row.order_date).to eq(19.days.ago.strftime("%m/%d/%Y"))
    expect(row.due_date).to eq("4 Days Overdue")
    expect(row.amount).to eq("$210.00")

    row = rows[1]
    expect(row.order_number).to eq("LO-003")
    expect(row.buyer).to eq("Money Bags")
    expect(row.order_date).to eq(2.days.ago.strftime("%m/%d/%Y"))
    expect(row.due_date).to eq(12.days.from_now.strftime("%m/%d/%Y"))
    expect(row.amount).to eq("$420.00")
  end

  it "allows the user to enter payment of an invoice" do
    Dom::Admin::Financials::InvoiceRow.first.enter_receipt

    select "Check", from: "Payment Method"
    fill_in "Note", with: "4321"

    click_button "Enter Receipt"

    expect(page).to have_content("Payment recorded for order LO-001")

    row = Dom::Admin::Financials::InvoiceRow.first
    expect(row.order_number).to eq("LO-003")
    expect(row.buyer).to eq("Money Bags")
    expect(row.order_date).to eq(2.days.ago.strftime("%m/%d/%Y"))
    expect(row.due_date).to eq(12.days.from_now.strftime("%m/%d/%Y"))
    expect(row.amount).to eq("$420.00")
  end
end
