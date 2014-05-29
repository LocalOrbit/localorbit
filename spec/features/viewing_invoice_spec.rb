require "spec_helper"

feature "Viewing invoices" do
  let(:market) { create(:market, :with_address, po_payment_term: 14) }
  let!(:market_manager) { create :user, managed_markets: [market] }

  let!(:buyer_user) { create :user }

  let!(:seller) { create(:organization, :seller, name: "Better Farms",   markets: [market]) }
  let!(:buyer)  { create(:organization, :buyer,  name: "Money Bags",     markets: [market], users: [buyer_user]) }
  let!(:buyer2) { create(:organization, :buyer,  name: "Money Satchels", markets: [market]) }

  let!(:product1) { create(:product, :sellable, organization: seller) }
  let!(:product2) { create(:product, :sellable, organization: seller) }

  let!(:order_item1) { create(:order_item, product: product1, unit_price: 210.00) }
  let!(:order_item2) { create(:order_item, product: product2, unit_price: 95.00, quantity: 2, quantity_delivered: 2, delivery_status: "delivered") }
  let!(:order_items) { [order_item1, order_item2] }
  let!(:order) { create(:order, items: order_items, market: market, organization: buyer, payment_method: 'purchase order', order_number: "LO-001", placed_at: Time.zone.parse("2014-04-01"), invoiced_at: Time.zone.parse("2014-04-02"), invoice_due_date: Time.zone.parse("2014-04-16")) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as market_manager
  end

  scenario "html content" do
    visit admin_invoice_path(order.id)

    expect(page).to have_content("Invoice Number LO-001")

    within('.invoice-basics') do
      expect(page).to have_content("Invoice Date 4/2/2014")
      expect(page).to have_content("Due Date 4/16/2014")
    end
    within('.invoice-parties') do
      expect(page).to have_content(market.name)

      address = market.addresses.first
      expect(page).to have_content(address.address)
      expect(page).to have_content(address.city)
      expect(page).to have_content(address.state)
      expect(page).to have_content(address.zip)
    end
    expect(page).to have_content("Total $400.00")

    # There should be 2 line items
    expect(all('.line-item').size).to eq(2)

    # Line items total
    expect(find('tr:last-child td:last-child')).to have_content("$400.00")
  end

  context "with lots" do
    let!(:product3)  { create(:product, :sellable, organization: seller, lots: [create(:lot, number: '123')]) }
    let!(:order_item3) { create(:order_item, product: product3, quantity: 4) }
    let!(:order_items) { [order_item1, order_item2, order_item3] }

    scenario "html content" do
      visit admin_invoice_path(order.id)

      expect(page).to have_content("Invoice Number LO-001")

      within('.invoice-basics') do
        expect(page).to have_content("Invoice Date 4/2/2014")
        expect(page).to have_content("Due Date 4/16/2014")
      end

      within('.invoice-parties') do
        expect(page).to have_content(market.name)

        address = market.addresses.first
        expect(page).to have_content(address.address)
        expect(page).to have_content(address.city)
        expect(page).to have_content(address.state)
        expect(page).to have_content(address.zip)
      end
      expect(page).to have_content("Total $427.96")

      # There should be 3 line items
      expect(all('.line-item').size).to eq(3)

      # Line items total
      expect(find('tr:last-child td:last-child')).to have_content("$427.96")
    end
  end

  scenario "generates a PDF of the content" do
    visit admin_invoice_path(order.id, format: 'pdf')

    expect(response_headers["Content-Type"]).to eq("application/pdf")
  end
end
