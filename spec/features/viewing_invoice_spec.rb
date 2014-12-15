require "spec_helper"

feature "Viewing invoices" do
  let(:market) { create(:market, po_payment_term: 14, contact_phone: "1234567890") }
  let!(:delivery_schedule) { create(:delivery_schedule, fee_type: "fixed", fee: "12.95") }
  let!(:delivery)    { delivery_schedule.next_delivery }
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
  let!(:order) do
    create(:order,
           delivery: delivery,
           items: order_items,
           market: market,
           organization: buyer,
           total_cost: order_items.sum(&:gross_total) + 12.95,
           payment_method: "purchase order",
           order_number: "LO-001",
           placed_at: Time.zone.parse("2014-04-01"),
           invoiced_at: Time.zone.parse("2014-04-02"),
           invoice_due_date: Time.zone.parse("2014-04-16"),
           delivery_fees: "12.95")
  end

  def expect_invoice_content
    expect(page).to have_content("Invoice Number LO-001")

    within(".invoice-basics") do
      expect(page).to have_content("Invoice Date 4/2/2014")
      expect(page).to have_content("Due Date 4/16/2014")
    end

    expect(page).to have_content(market.name)

    expect(page).to have_content("Subtotal $400.00")
    expect(page).to have_content("Total $412.95")

    # There should be 2 line items
    expect(all(".line-item").size).to eq(2)
  end

  def expect_market_address
    within(".invoice-parties") do
      address = market.addresses.visible.first
      expect(page).to have_content(address.address)
      expect(page).to have_content(address.city)
      expect(page).to have_content(address.state)
      expect(page).to have_content(address.zip)
      expect(page).to have_content("(123) 456-7890")
      expect(page).to have_content(market.contact_email)
    end
  end

  context "no market address" do
    context "as a buyer" do
      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(buyer_user)
      end

      scenario "html content" do
        visit peek_admin_invoice_path(order.id)

        expect_invoice_content

        # Line items total
        expect(find("tr:last-child td:last-child")).to have_content("$412.95")
        expect(page).to have_content("Subtotal $400.00")
      end
    end
  end

  context "market has an address" do
    let!(:market_address) { create(:market_address, market: market) }
    context "as a buyer" do
      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(buyer_user)
      end

      scenario "html content" do
        visit peek_admin_invoice_path(order.id)

        expect_invoice_content
        expect_market_address

        # Line items total
        expect(find("tr:last-child td:last-child")).to have_content("$412.95")
        expect(page).to have_content("Subtotal $400.00")
      end
    end

    context "as a market manager" do
      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as market_manager
      end

      scenario "html content" do
        visit peek_admin_invoice_path(order.id)

        expect(page).to have_content("Invoice Number LO-001")

        within(".invoice-basics") do
          expect(page).to have_content("Invoice Date 4/2/2014")
          expect(page).to have_content("Due Date 4/16/2014")
        end
        within(".invoice-parties") do
          expect(page).to have_content(market.name)

          address = market.addresses.first
          expect(page).to have_content(address.address)
          expect(page).to have_content(address.city)
          expect(page).to have_content(address.state)
          expect(page).to have_content(address.zip)
          expect(page).to have_content("(123) 456-7890")
          expect(page).to have_content(market.contact_email)
        end

        expect(page).to have_content("Subtotal $400.00")
        expect(page).to have_content("Total $412.95")

        # There should be 2 line items
        expect(all(".line-item").size).to eq(2)

        # Line items total
        expect(find("tr:last-child td:last-child")).to have_content("$412.95")
      end

      scenario "generate invoice PDF preview", :js do
        # Tweak order so it appears in the Send Invoices tab:
        # 1. it needs not to be invoiced already
        # 2. it needs to be placed recently, to stay inside the default date filter
        order.update(invoiced_at: nil, invoice_due_date: nil, placed_at: 1.day.ago)
        expect(order.invoice_pdf).to be nil # be sure there's no attached invoice

        # Go to the list
        visit admin_financials_invoices_path

        # Click Preview for this order:
        row = Dom::Admin::Financials::InvoiceRow.find_by_order_number(order.order_number)
        row.preview

        patiently do
          expect(page).to have_text("Generating invoice for #{order.order_number}...")
        end

        patiently do
          uid = current_path[1..-1]
          the_order = Order.find_by(invoice_pdf_uid: uid)
          expect(the_order).to be
          expect(the_order.invoice_pdf).to be
          expect(the_order.invoice_pdf.file).to be
          expect(the_order.invoice_pdf.file.readlines.first).to match(/PDF-1\.4/)
        end
      end

      context "with irregular phone numbers" do
        before do
          market.update_attribute(:contact_phone, "+123 (456) 789-0987 ext. 654")
        end

        scenario "html content" do
          visit peek_admin_invoice_path(order.id)

          expect(page).to have_content("Invoice Number LO-001")

          within(".invoice-parties") do
            expect(page).to have_content("+123 (456) 789-0987 ext. 654")
          end
        end
      end

      context "with lots" do
        let!(:product3)  { create(:product, :sellable, organization: seller, lots: [create(:lot, number: "123")]) }
        let!(:order_item3) { create(:order_item, product: product3, quantity: 4) }
        let!(:order_items) { [order_item1, order_item2, order_item3] }

        scenario "html content" do
          visit peek_admin_invoice_path(order.id)

          expect(page).to have_content("Invoice Number LO-001")

          within(".invoice-basics") do
            expect(page).to have_content("Invoice Date 4/2/2014")
            expect(page).to have_content("Due Date 4/16/2014")
          end

          within(".invoice-parties") do
            expect(page).to have_content(market.name)

            address = market.addresses.first
            expect(page).to have_content(address.address)
            expect(page).to have_content(address.city)
            expect(page).to have_content(address.state)
            expect(page).to have_content(address.zip)
          end
          expect(page).to have_content("Subtotal $427.96")
          expect(page).to have_content("Total $440.91")

          # There should be 3 line items
          expect(all(".line-item").size).to eq(3)

          # Line items total
          expect(find("tr:last-child td:last-child")).to have_content("$440.91")
        end
      end

    end
  end
end
