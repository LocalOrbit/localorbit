require "spec_helper"

feature "Viewing invoices" do
  let(:market) { create(:market, :with_address, po_payment_term: 14) }
  let!(:market_manager) { create :user, managed_markets: [market] }

  let!(:buyer_user) { create :user }

  let!(:seller) { create(:organization, :seller, name: "Better Farms", markets: [market]) }
  let!(:buyer)  { create(:organization, :buyer, name: "Money Bags", markets: [market], users: [buyer_user]) }
  let!(:buyer2) { create(:organization, :buyer, name: "Money Satchels", markets: [market]) }

  let!(:product) { create(:product, :sellable, organization: seller) }

  let!(:order) { create(:order, items:[create(:order_item, product: product)], market: market, organization: buyer, payment_method: 'purchase order', order_number: "LO-001", total_cost: 210, placed_at: Time.zone.parse("2014-04-01"), invoiced_at: Time.zone.parse("2014-04-02"), invoice_due_date: Time.zone.parse("2014-04-16")) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as market_manager
  end

  scenario "html content" do
    visit admin_invoice_path(order.id)

    within('.invoice-top') do
      expect(page).to have_content(market.name)

      address = market.addresses.first
      expect(page).to have_content(address.address)
      expect(page).to have_content(address.city)
      expect(page).to have_content(address.state)
      expect(page).to have_content(address.zip)

      expect(page).to have_content("Invoice Number: LO-001")
      expect(page).to have_content("Invoice Date: April 02, 2014")
      expect(page).to have_content("Payment Due: April 16, 2014")
      expect(page).to have_content("Amount Due: $210.00")
    end

    # There should be one line item
    expect(all('.line-item').size).to eq(1)

    # Line items total
    expect(find('tr:last-child td:last-child')).to have_content("$210.00")
  end

  scenario "generates a PDF of the content" do
    visit admin_invoice_path(order.id, format: 'pdf')

    expect(response_headers["Content-Type"]).to eq("application/pdf")
  end
end
