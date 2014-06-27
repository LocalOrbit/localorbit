require "spec_helper"

feature "sending invoices" do
  let(:market1) { create(:market, subdomain: 'betterest', po_payment_term: 14) }
  let!(:market_manager) { create :user, managed_markets: [market1] }
  let!(:delivery_schedule) { create(:delivery_schedule) }
  let!(:delivery)    { delivery_schedule.next_delivery }


  let!(:buyer_user) { create :user }

  let!(:market1_seller1) { create(:organization, :seller, name: "Better Farms", markets: [market1]) }
  let!(:market1_buyer1)  { create(:organization, :buyer, name: "Money Bags", markets: [market1], users: [buyer_user]) }
  let!(:market1_buyer2) { create(:organization, :buyer, name: "Money Satchels", markets: [market1]) }

  let!(:product) { create(:product, :sellable, organization: market1_seller1) }

  let!(:market1_order1) { create(:order, delivery: delivery, items:[create(:order_item, product: product, unit_price: 210.00)], market: market1, organization: market1_buyer1, payment_method: 'purchase order', order_number: "LO-001", total_cost: 210, placed_at: 1.week.ago) }
  let!(:market1_order2) { create(:order, delivery: delivery, items:[create(:order_item, product: product)], market: market1, organization: market1_buyer1, invoiced_at: 1.day.ago, invoice_due_date: 13.days.from_now) }
  let!(:market1_order3) { create(:order, delivery: delivery, items:[create(:order_item, product: product)], market: market1, organization: market1_buyer1, payment_method: 'credit card') }
  let!(:market1_order4) { create(:order, delivery: delivery, items:[create(:order_item, product: product)], market: market1, organization: market1_buyer1, payment_method: 'ach') }
  let!(:market1_order5) { create(:order, delivery: delivery, items:[create(:order_item, product: product, unit_price: 420.00)], market: market1, organization: market1_buyer1, payment_method: 'purchase order', order_number: "LO-005", total_cost: 420, placed_at: 2.weeks.ago) }
  let!(:market1_order6) { create(:order, delivery: delivery, items:[create(:order_item, product: product, unit_price: 310.00)], market: market1, organization: market1_buyer2, payment_method: 'purchase order', order_number: "LO-006", total_cost: 310, placed_at: 3.weeks.ago) }

  invoice_auth_matcher = lambda {|r1, r2|
    matcher = %r{/admin/invoices/[0-9]+/invoice\.pdf\?auth_token=}
    matcher.match(r1.uri) && matcher.match(r2.uri)
  }

  scenario "seeing a list of unsent invoices" do
    switch_to_subdomain(market1.subdomain)
    sign_in_as market_manager
    visit admin_financials_invoices_path

    # Orders paid with PO payment type, that have no invoiced_at time
    invoice_rows = Dom::Admin::Financials::InvoiceRow.all
    expect(invoice_rows.size).to eq(3)

    invoice = invoice_rows.first

    expect(invoice.order_number).to eq("LO-001")
    expect(invoice.buyer).to eq("Money Bags")
    expect(invoice.order_date).to eq(1.week.ago.strftime("%m/%d/%Y"))
    expect(invoice.amount).to eq("$210.00")
    expect(invoice.delivery_status).to eq("Pending")
    expect(invoice.action).to include("Send Invoice")
    expect(invoice.action).to include("Preview")
  end

  scenario "sending a invoice", vcr: {match_requests_on: [:host, invoice_auth_matcher]} do
    switch_to_subdomain(market1.subdomain)
    sign_in_as market_manager
    visit admin_financials_invoices_path

    Dom::Admin::Financials::InvoiceRow.first.send_invoice

    expect(page).to have_content("Invoice sent for order number LO-001")
    expect(Dom::Admin::Financials::InvoiceRow.all.size).to eq(2)

    open_email(buyer_user.email)

    expect(current_email).to have_subject("New Invoice")
    expect(current_email).to have_body_text("Invoice")
    expect(current_email).to have_body_text("Reference Number: LO-001")
    expect(current_email.attachments.size).to eq(1)

    attachment = current_email.attachments.first
    expect(attachment.filename).to eq("invoice.pdf")
    expect(attachment.content_type).to eq("application/pdf; charset=UTF-8")
  end

  scenario "sending an invoice to an organization with no users" do
    switch_to_subdomain(market1.subdomain)
    sign_in_as market_manager
    visit admin_financials_invoices_path

    Dom::Admin::Financials::InvoiceRow.all.last.send_invoice

    expect(page).to have_content("Invoice sent for order number LO-006")
    expect(Dom::Admin::Financials::InvoiceRow.all.size).to eq(2)

    expect(ActionMailer::Base.deliveries.size).to eq(0)
  end

  scenario "sending selected invoices", :js, vcr: {match_requests_on: [:host, invoice_auth_matcher]} do
    switch_to_subdomain(market1.subdomain)
    sign_in_as market_manager
    visit admin_financials_invoices_path

    Dom::Admin::Financials::InvoiceRow.select_all
    click_button 'Send Selected Invoices'

    expect(page).to have_content("Invoice sent for order numbers LO-001, LO-005, LO-006")
    expect(Dom::Admin::Financials::InvoiceRow.all.size).to eq(0)
  end

  context "filtering" do
    let!(:market2) { create(:market, subdomain: 'betterest2', po_payment_term: 14) }
    let!(:delivery_schedule2) { create(:delivery_schedule) }
    let!(:delivery2) { delivery_schedule.next_delivery }
    let!(:market_manager) { create :user, managed_markets: [market1, market2] }
    let!(:buyer_user2) { create :user }
    let!(:market2_seller1) { create(:organization, :seller, name: "Better Farms", markets: [market2]) }
    let!(:market2_buyer1)  { create(:organization, :buyer, name: "Buyer for Market2 1", markets: [market2], users: [buyer_user2]) }
    let!(:market2_buyer2) { create(:organization, :buyer, name: "Buyer for Market 2 1", markets: [market2]) }
    let!(:market2_order1) { create(:order, delivery: delivery2, items:[create(:order_item, product: product, unit_price: 210.00)], market: market2, organization: market2_buyer1, payment_method: 'purchase order', order_number: "LO-007", total_cost: 210, placed_at: 1.week.ago) }
    let!(:market2_order2) { create(:order, delivery: delivery2, items:[create(:order_item, product: product)], market: market2, organization: market2_buyer1, invoiced_at: 1.day.ago, invoice_due_date: 13.days.from_now) }
    let!(:market2_order3) { create(:order, delivery: delivery2, items:[create(:order_item, product: product)], market: market2, organization: market2_buyer1, payment_method: 'credit card') }
    let!(:market2_order4) { create(:order, delivery: delivery2, items:[create(:order_item, product: product)], market: market2, organization: market2_buyer1, payment_method: 'ach') }
    let!(:market2_order5) { create(:order, delivery: delivery2, items:[create(:order_item, product: product, unit_price: 420.00)], market: market2, organization: market2_buyer1, payment_method: 'purchase order', order_number: "LO-008", total_cost: 420, placed_at: 2.weeks.ago) }
    let!(:market2_order6) { create(:order, delivery: delivery2, items:[create(:order_item, product: product, unit_price: 310.00)], market: market2, organization: market2_buyer2, payment_method: 'purchase order', order_number: "LO-009", total_cost: 310, placed_at: 3.weeks.ago) }
    let!(:market2_order7) { create(:order, delivery: delivery2, items:[create(:order_item, product: product, unit_price: 110.00)], market: market2, organization: market2_buyer2, payment_method: 'purchase order', order_number: "LO-010", total_cost: 110, placed_at: 5.weeks.ago) }

    it "can be filtered by market" do
      switch_to_subdomain(market1.subdomain)
      sign_in_as market_manager
      visit admin_financials_invoices_path

      within("#q_market_id_eq") do
        expect(page).to have_content(market1.name)
        expect(page).to have_content(market2.name)
      end

      within("#q_organization_id_eq") do
        expect(page).to have_content(market1_buyer1.name)
        expect(page).to have_content(market1_buyer2.name)
        expect(page).to have_content(market2_buyer2.name)
        expect(page).to have_content(market2_buyer1.name)
      end

      expect(page).to have_content(market1_order1.order_number)
      expect(page).not_to have_content(market1_order2.order_number)
      expect(page).not_to have_content(market1_order3.order_number)
      expect(page).not_to have_content(market1_order4.order_number)
      expect(page).to have_content(market1_order5.order_number)
      expect(page).to have_content(market1_order6.order_number)

      expect(page).to have_content(market2_order1.order_number)
      expect(page).not_to have_content(market2_order2.order_number)
      expect(page).not_to have_content(market2_order3.order_number)
      expect(page).not_to have_content(market2_order4.order_number)
      expect(page).to have_content(market2_order5.order_number)
      expect(page).to have_content(market2_order6.order_number)

      select market1.name, from: "q_market_id_eq"
      click_button "Filter"

      expect(page).to have_content(market1_order1.order_number)
      expect(page).not_to have_content(market1_order2.order_number)
      expect(page).not_to have_content(market1_order3.order_number)
      expect(page).not_to have_content(market1_order4.order_number)
      expect(page).to have_content(market1_order5.order_number)
      expect(page).to have_content(market1_order6.order_number)

      expect(page).not_to have_content(market2_order1.order_number)
      expect(page).not_to have_content(market2_order2.order_number)
      expect(page).not_to have_content(market2_order3.order_number)
      expect(page).not_to have_content(market2_order4.order_number)
      expect(page).not_to have_content(market2_order5.order_number)
      expect(page).not_to have_content(market2_order6.order_number)
      expect(page).not_to have_content(market2_order7.order_number)

      within("#q_organization_id_eq") do
        expect(page).to have_content(market1_buyer1.name)
        expect(page).to have_content(market1_buyer2.name)
        expect(page).not_to have_content(market2_buyer2.name)
        expect(page).not_to have_content(market2_buyer1.name)
      end
    end

    it "can be filtered by organization" do
      switch_to_subdomain(market1.subdomain)
      sign_in_as market_manager
      visit admin_financials_invoices_path

      select market1_buyer2.name, from: "q_organization_id_eq"
      click_button "Filter"

      expect(page).not_to have_content(market1_order1.order_number)
      expect(page).not_to have_content(market1_order2.order_number)
      expect(page).not_to have_content(market1_order3.order_number)
      expect(page).not_to have_content(market1_order4.order_number)
      expect(page).not_to have_content(market1_order5.order_number)
      expect(page).to have_content(market1_order6.order_number)

      expect(page).not_to have_content(market2_order1.order_number)
      expect(page).not_to have_content(market2_order2.order_number)
      expect(page).not_to have_content(market2_order3.order_number)
      expect(page).not_to have_content(market2_order4.order_number)
      expect(page).not_to have_content(market2_order5.order_number)
      expect(page).not_to have_content(market2_order6.order_number)
    end

    it "can be filtered by date" do
      switch_to_subdomain(market1.subdomain)
      sign_in_as market_manager
      visit admin_financials_invoices_path

      expect(page).to have_content(market1_order1.order_number)
      expect(page).not_to have_content(market1_order2.order_number)
      expect(page).not_to have_content(market1_order3.order_number)
      expect(page).not_to have_content(market1_order4.order_number)
      expect(page).to have_content(market1_order5.order_number)
      expect(page).to have_content(market1_order6.order_number)

      expect(page).to have_content(market2_order1.order_number)
      expect(page).not_to have_content(market2_order2.order_number)
      expect(page).not_to have_content(market2_order3.order_number)
      expect(page).not_to have_content(market2_order4.order_number)
      expect(page).to have_content(market2_order5.order_number)
      expect(page).to have_content(market2_order6.order_number)
      expect(page).not_to have_content(market2_order7.order_number)

      fill_in "q_placed_at_date_gteq", with: 6.weeks.ago.to_date
      click_button "Filter"

      expect(page).to have_content(market1_order1.order_number)
      expect(page).not_to have_content(market1_order2.order_number)
      expect(page).not_to have_content(market1_order3.order_number)
      expect(page).not_to have_content(market1_order4.order_number)
      expect(page).to have_content(market1_order5.order_number)
      expect(page).to have_content(market1_order6.order_number)

      expect(page).to have_content(market2_order1.order_number)
      expect(page).not_to have_content(market2_order2.order_number)
      expect(page).not_to have_content(market2_order3.order_number)
      expect(page).not_to have_content(market2_order4.order_number)
      expect(page).to have_content(market2_order5.order_number)
      expect(page).to have_content(market2_order6.order_number)
      expect(page).to have_content(market2_order7.order_number)

      fill_in "q_placed_at_date_lteq", with: 3.weeks.ago.to_date
      click_button "Filter"

      expect(page).not_to have_content(market1_order1.order_number)
      expect(page).not_to have_content(market1_order2.order_number)
      expect(page).not_to have_content(market1_order3.order_number)
      expect(page).not_to have_content(market1_order4.order_number)
      expect(page).not_to have_content(market1_order5.order_number)
      expect(page).to have_content(market1_order6.order_number)

      expect(page).not_to have_content(market2_order1.order_number)
      expect(page).not_to have_content(market2_order2.order_number)
      expect(page).not_to have_content(market2_order3.order_number)
      expect(page).not_to have_content(market2_order4.order_number)
      expect(page).not_to have_content(market2_order5.order_number)
      expect(page).to have_content(market2_order6.order_number)
      expect(page).to have_content(market2_order7.order_number)
    end

    it "can be filtered by order number" do
      switch_to_subdomain(market1.subdomain)
      sign_in_as market_manager
      visit admin_financials_invoices_path

      expect(page).to have_content(market1_order1.order_number)
      expect(page).not_to have_content(market1_order2.order_number)
      expect(page).not_to have_content(market1_order3.order_number)
      expect(page).not_to have_content(market1_order4.order_number)
      expect(page).to have_content(market1_order5.order_number)
      expect(page).to have_content(market1_order6.order_number)

      fill_in "q_order_number_or_payment_note_cont", with: "LO-001"
      click_button "Filter"

      expect(page).to have_content(market1_order1.order_number)
      expect(page).not_to have_content(market1_order2.order_number)
      expect(page).not_to have_content(market1_order3.order_number)
      expect(page).not_to have_content(market1_order4.order_number)
      expect(page).not_to have_content(market1_order5.order_number)
      expect(page).not_to have_content(market1_order6.order_number)

      expect(page.find("#q_order_number_or_payment_note_cont").value).to eql("LO-001")
    end

    context "users who have only 1 market" do
      let!(:market_manager) { create :user, managed_markets: [market1] }

      scenario "won't see the option to filter by market" do
        switch_to_subdomain(market1.subdomain)
        sign_in_as market_manager
        visit admin_financials_invoices_path

        expect(page).not_to have_select("Market")
      end
    end
  end

end
