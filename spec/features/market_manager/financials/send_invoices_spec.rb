require "spec_helper"

feature "sending invoices" do
  let(:market) { create(:market, po_payment_term: 14) }
  let!(:market_manager) { create :user, managed_markets: [market] }

  let!(:seller) { create(:organization, :seller, name: "Better Farms", markets: [market]) }
  let!(:buyer)  { create(:organization, :buyer, name: "Money Bags", markets: [market]) }

  let!(:product) { create(:product, :sellable, organization: seller) }

  let!(:order1) { create(:order, market: market, organization: buyer, payment_method: 'purchase order', order_number: "LO-001", total_cost: 210, placed_at: Time.zone.parse("2014-04-01")) }
  let!(:order_item1) { create(:order_item, order: order1, product: product) }
  let!(:order2) { create(:order, market: market, organization: buyer, invoiced_at: 1.day.ago, invoice_due_date: 13.days.from_now) }
  let!(:order_item2) { create(:order_item, order: order2, product: product) }
  let!(:order3) { create(:order, market: market, organization: buyer, payment_method: 'credit card') }
  let!(:order_item3) { create(:order_item, order: order3, product: product) }
  let!(:order4) { create(:order, market: market, organization: buyer, payment_method: 'ach') }
  let!(:order_item4) { create(:order_item, order: order4, product: product) }
  let!(:order5) { create(:order, market: market, organization: buyer, payment_method: 'purchase order', order_number: "LO-005", total_cost: 420, placed_at: Time.zone.parse("2014-04-02")) }
  let!(:order_item5) { create(:order_item, order: order5, product: product) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as market_manager
    visit admin_financials_invoices_path
  end

  scenario "seeing a list of unsent invoices" do
    # Orders paid with PO payment type, that have no invoiced_at time
    invoice_rows = Dom::Admin::Financials::UnsentInvoiceRow.all
    expect(invoice_rows.size).to eq(2)

    invoice = invoice_rows.first

    expect(invoice.order_number).to eq("LO-001")
    expect(invoice.buyer).to eq("Money Bags")
    expect(invoice.order_date).to eq("04/01/2014")
    expect(invoice.amount).to eq("$210.00")
  end

  scenario "sending a invoice" do
    Dom::Admin::Financials::UnsentInvoiceRow.first.send_invoice

    expect(page).to have_content("Invoice sent for order number LO-001")
    expect(Dom::Admin::Financials::UnsentInvoiceRow.all.size).to eq(1)
  end

  scenario "sending selected invoices", js: true do
    Dom::Admin::Financials::UnsentInvoiceRow.select_all
    click_button 'Send Selected Invoices'

    expect(page).to have_content("Invoice sent for order numbers LO-001, LO-005")
    expect(Dom::Admin::Financials::UnsentInvoiceRow.all.size).to eq(0)
  end
end