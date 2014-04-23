require "spec_helper"

feature "sending invoices" do
  let(:market) { create(:market, po_payment_term: 14) }
  let!(:market_manager) { create :user, managed_markets: [market] }

  let!(:buyer_user) { create :user }

  let!(:seller) { create(:organization, :seller, name: "Better Farms", markets: [market]) }
  let!(:buyer)  { create(:organization, :buyer, name: "Money Bags", markets: [market], users: [buyer_user]) }
  let!(:buyer2) { create(:organization, :buyer, name: "Money Satchels", markets: [market]) }

  let!(:product) { create(:product, :sellable, organization: seller) }

  let!(:order1) { create(:order, items:[create(:order_item, product: product)], market: market, organization: buyer, payment_method: 'purchase order', order_number: "LO-001", total_cost: 210, placed_at: Time.zone.parse("2014-04-01")) }
  let!(:order2) { create(:order, items:[create(:order_item, product: product)], market: market, organization: buyer, invoiced_at: 1.day.ago, invoice_due_date: 13.days.from_now) }
  let!(:order3) { create(:order, items:[create(:order_item, product: product)], market: market, organization: buyer, payment_method: 'credit card') }
  let!(:order4) { create(:order, items:[create(:order_item, product: product)], market: market, organization: buyer, payment_method: 'ach') }
  let!(:order5) { create(:order, items:[create(:order_item, product: product)], market: market, organization: buyer, payment_method: 'purchase order', order_number: "LO-005", total_cost: 420, placed_at: Time.zone.parse("2014-04-02")) }
  let!(:order6) { create(:order, items:[create(:order_item, product: product)], market: market, organization: buyer2, payment_method: 'purchase order', order_number: "LO-006", total_cost: 310, placed_at: Time.zone.parse("2014-04-03")) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as market_manager
    visit admin_financials_invoices_path
  end

  scenario "seeing a list of unsent invoices" do
    # Orders paid with PO payment type, that have no invoiced_at time
    invoice_rows = Dom::Admin::Financials::InvoiceRow.all
    expect(invoice_rows.size).to eq(3)

    invoice = invoice_rows.first

    expect(invoice.order_number).to eq("LO-001")
    expect(invoice.buyer).to eq("Money Bags")
    expect(invoice.order_date).to eq("04/01/2014")
    expect(invoice.amount).to eq("$210.00")
  end

  scenario "sending a invoice" do
    Dom::Admin::Financials::InvoiceRow.first.send_invoice

    expect(page).to have_content("Invoice sent for order number LO-001")
    expect(Dom::Admin::Financials::InvoiceRow.all.size).to eq(2)

    open_email(buyer_user.email)

    expect(current_email).to have_subject("New Invoice")
    expect(current_email).to have_body_text("Invoice")
    expect(current_email).to have_body_text("Reference Number: LO-001")
  end

  scenario "sending an invoice to an organization with no users" do
    Dom::Admin::Financials::InvoiceRow.all.last.send_invoice

    expect(page).to have_content("Invoice sent for order number LO-006")
    expect(Dom::Admin::Financials::InvoiceRow.all.size).to eq(2)

    expect(ActionMailer::Base.deliveries.size).to eq(0)
  end

  scenario "sending selected invoices", js: true do
    Dom::Admin::Financials::InvoiceRow.select_all
    click_button 'Send Selected Invoices'

    expect(page).to have_content("Invoice sent for order numbers LO-001, LO-005, LO-006")
    expect(Dom::Admin::Financials::InvoiceRow.all.size).to eq(0)
  end
end
