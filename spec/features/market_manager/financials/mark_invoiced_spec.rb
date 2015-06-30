require "spec_helper"

feature "sending invoices" do
  let(:market1)            { create(:market, subdomain: "betterest", po_payment_term: 14) }
  let!(:market_manager)    { create :user, managed_markets: [market1] }
  let!(:delivery_schedule) { create(:delivery_schedule) }
  let!(:delivery)          { delivery_schedule.next_delivery }

  let!(:buyer_user) { create :user }

  let!(:market1_seller1) { create(:organization, :seller, name: "Better Farms", markets: [market1]) }
  let!(:market1_buyer1)  { create(:organization, :buyer, name: "Money Bags", markets: [market1], users: [buyer_user]) }
  let!(:market1_buyer2)  { create(:organization, :buyer, name: "Money Satchels", markets: [market1]) }

  let!(:product) { create(:product, :sellable, organization: market1_seller1) }

  let!(:market1_order1) { create(:order, delivery: delivery, items: [create(:order_item, product: product, unit_price: 210.00)], market: market1, organization: market1_buyer1, payment_method: "purchase order", order_number: "LO-001", total_cost: 210, placed_at: 1.week.ago) }
  let!(:market1_order2) { create(:order, delivery: delivery, items: [create(:order_item, product: product)], market: market1, organization: market1_buyer1, invoiced_at: 1.day.ago, invoice_due_date: 13.days.from_now) }
  let!(:market1_order3) { create(:order, delivery: delivery, items: [create(:order_item, product: product)], market: market1, organization: market1_buyer1, payment_method: "credit card") }
  let!(:market1_order4) { create(:order, delivery: delivery, items: [create(:order_item, product: product)], market: market1, organization: market1_buyer1, payment_method: "ach") }
  let!(:market1_order5) { create(:order, delivery: delivery, items: [create(:order_item, product: product, unit_price: 420.00)], market: market1, organization: market1_buyer1, payment_method: "purchase order", order_number: "LO-005", total_cost: 420, placed_at: 2.weeks.ago) }
  let!(:market1_order6) { create(:order, delivery: delivery, items: [create(:order_item, product: product, unit_price: 310.00)], market: market1, organization: market1_buyer2, payment_method: "purchase order", order_number: "LO-006", total_cost: 310, placed_at: 3.weeks.ago) }

  invoice_auth_matcher = lambda do|r1, r2|
    matcher = %r{/admin/invoices/[0-9]+/invoice\.pdf\?auth_token=}
    matcher.match(r1.uri) && matcher.match(r2.uri)
  end

  context "Mark Selected Invoice" do
    before do
      switch_to_subdomain(market1.subdomain)
      sign_in_as market_manager
      visit admin_financials_invoices_path
    end

    context "without selecting any invoices" do
      it "fails", :js do
        # (select nothing)
        click_mark_selected_invoiced
        expect(page).to have_content("Please select one or more invoices to mark")
      end
    end

    context "marking a specific invoice by clicking its individual link" do
      let(:order) { market1_order1 }

      it "marks it as invoiced and moves it off the page", :js do

        row = invoice_row_for(order: order)
        expect(row).to be

        now = Time.current

        row.mark_invoiced

        expect(page).to have_content("Invoice marked for order number #{order.order_number}")

        expect(invoice_row_for(order: order)).to be nil

        order.reload
        expect(order.invoiced_at).to be_within(5.seconds).of(now)
        expect(order.invoice_due_date).to be_within(5.seconds).of(market1.po_payment_term.days.from_now(now))

      end
    end

    context "selecting multiple invoices and clicking Mark Selected Invoiced" do
      let(:orders) {[
        market1_order1,
        market1_order6,
      ]}

      it "marks selected orders as invoiced", :js do

        # sanity check: orders should have no invoice info beforehand:
        orders.each do |order|
          expect(order.invoiced_at).to be nil
          expect(order.invoice_due_date).to be nil
        end

        orders.each do |o|
          invoice_row_for(order: o).check_row
        end

        now = Time.current

        click_mark_selected_invoiced

        expect(page).to have_content("Invoice marked for order numbers #{orders.map { |o| o.order_number }.join(', ')}")

        # See the orders gone from this page:
        orders.each do |order|
          expect(invoice_row_for(order: order)).to eq nil
        end

        # See the invoice timestamps on the orders:
        orders.each do |order|
          order.reload
          expect(order.invoiced_at).to be_within(5.seconds).of(now)
          expect(order.invoice_due_date).to be_within(5.seconds).of(market1.po_payment_term.days.from_now(now))
        end
      end
    end
  end

  def click_mark_selected_invoiced
    suppressing_new_tab do
      click_button "Mark Selected Invoiced"
      expect(internal_server_error_message).to be_nil
    end
  end

  def suppressing_new_tab()
    page.execute_script %|$("#invoice-list").prop("data-suppress-target","1")|
    begin
      yield
    ensure
      begin
        page.execute_script %|$("#invoice-list").prop("data-suppress-target",null)|
      rescue Exception => e2
        puts "(Couldn't clear the data-suppress-target data attribute from #invoice-list, probably due to an error or being on a different page.)"
      end
    end
  end

  def internal_server_error_message
    if text =~ /internal server error/i
      text
    else
      nil
    end
  end

  def invoice_row_for(order:)
    Dom::Admin::Financials::InvoiceRow.find_by_order_number(order.order_number)
  end

end
