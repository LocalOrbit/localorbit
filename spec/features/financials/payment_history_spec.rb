require "spec_helper"

def format_date(date)
  date.strftime("%m/%d/%Y")
end

def get_results(num_results)
  link_char = (current_url.include? "?") ? "&" : "?"
  visit(current_url + link_char + "per_page=" + num_results.to_s)
end

feature "Payment history", :truncate_after_all do
  def remember_payment(payment)
    @payments[payment.created_at.strftime("%m/%d/%Y")] = payment.orders.map(&:order_number).join(",")
  end

  before :all do
    market_ach_balanced_uri = "/v1/marketplaces/TEST-MP4X7mSSQwAyDzwUfc5TAQ7D/bank_accounts/BA6MvUHwvMFA1EtwhPT5F2sT"
    ach_balanced_uri        = "/v1/marketplaces/TEST-MP4X7mSSQwAyDzwUfc5TAQ7D/bank_accounts/BA1YqNWvILpfyq9FqSDPLhCO"
    other_ach_balanced_uri  = "/v1/marketplaces/TEST-MP4X7mSSQwAyDzwUfc5TAQ7D/bank_accounts/BA1R1oClZ5QiHNzj0D9KNMKC"
    cc_balanced_uri         = "/v1/marketplaces/TEST-MP4X7mSSQwAyDzwUfc5TAQ7D/cards/CC4O7hP4aRjIkvqRC2wwr4i5"

    delivery_schedule = create(:delivery_schedule)
    @delivery = delivery_schedule.next_delivery

    @market  = create(:market, po_payment_term: 30, timezone: "Eastern Time (US & Canada)")
    @market2 = create(:market, po_payment_term: 30, timezone: "Eastern Time (US & Canada)")
    market3  = create(:market, po_payment_term: 30, timezone: "Eastern Time (US & Canada)")
    create(:bank_account, :checking, last_four: "7676", balanced_uri: market_ach_balanced_uri, bankable: @market)

    @buyer   = create(:organization, :buyer,  name: "Buyer",    markets: [@market])
    @buyer2  = create(:organization, :buyer,  name: "Buyer 2",  markets: [@market2, market3])
    @seller  = create(:organization, :seller, name: "Seller",   markets: [@market])
    @seller2 = create(:organization, :seller, name: "Seller 2", markets: [@market2])

    @payment_day = 20.days.ago

    ach_account       = create(:bank_account, :checking,    last_four: "9983", balanced_uri: ach_balanced_uri,       bankable: @buyer)
    other_ach_account = create(:bank_account, :checking,    last_four: "2231", balanced_uri: other_ach_balanced_uri, bankable: @buyer)
    cc_account        = create(:bank_account, :credit_card, last_four: "7732", balanced_uri: cc_balanced_uri,        bankable: @buyer)

    order_item = create(:order_item, unit_price: 6.50, quantity: 2)
    create(:order, delivery: @delivery, items: [order_item], organization: @buyer, payment_method: "purchase order", total_cost: 13.00)

    order_item = create(:order_item, unit_price: 36.00, quantity: 2)
    create(:order, delivery: @delivery, items: [order_item], organization: @buyer, payment_method: "ach", total_cost: 72.00)

    order_item = create(:order_item, unit_price: 129.00, quantity: 1)
    create(:order, delivery: @delivery, items: [order_item], organization: @buyer, payment_method: "credit card", total_cost: 129.00)

    @payments = {}

    @orders = []
    @orders2 = []
    6.times do |i|
      order_item = create(:order_item, 
                          unit_price: 20.00 + i, 
                          quantity: 1, 
                          product: create(:product, :sellable, 
                                          organization: @seller))
      @orders << create(:order,
                       market: @market,
                       delivery: @delivery,
                       items: [order_item],
                       organization: @buyer,
                       payment_method: ["purchase order", "purchase order", "purchase order", "ach", "ach", "credit card"][i],
                       payment_status: "paid",
                       order_number: "LO-01-234-4567890-#{i}",
                       total_cost: 20.00 + i
                       )
      order_item2 = create(:order_item, 
                           unit_price: 20.01 + i, 
                           quantity: 1,
                           product: create(:product, :sellable, 
                                          organization: @seller2))
      @orders2 << create(:order,
                        market: @market2,
                        delivery: @delivery,
                        items: [order_item2],
                        organization: @buyer2,
                        payment_method: ["purchase order", "purchase order", "purchase order", "ach", "ach", "credit card"][i],
                        payment_status: "paid",
                        order_number: "LO-02-234-4567890-#{i}",
                        total_cost: 20.01 + i
                       )
    end

    (1..5).each do |i|
      Timecop.freeze(@payment_day + i.days) do
        # Create payment from buyer to market
        payment = create(:payment,
                         payment_method: ["cash", "check", "ach", "ach", "credit card"][i - 1],
                         payer: @buyer,
                         payee: @market,
                         orders: [@orders[i]],
                         amount: @orders[i].total_cost)

        payment.update_attribute(:note, "#12345") if i == 2
        payment.update_attributes(bank_account: ach_account) if i == 3
        payment.update_attributes(bank_account: other_ach_account, status: "pending") if i == 4
        payment.update_attributes(bank_account: cc_account) if i == 5
        remember_payment(payment)

        payment2 = create(:payment,
                          payment_method: ["cash", "check", "ach", "ach", "credit card"][i - 1],
                          payer: @buyer2,
                          payee: @market2,
                          orders: [@orders2[i]],
                          amount: @orders2[i].total_cost)

        payment2.update_attribute(:note, "#12345") if i == 2
        payment2.update_attributes(bank_account: ach_account) if i == 3
        payment2.update_attributes(bank_account: other_ach_account, status: "pending") if i == 4
        payment2.update_attributes(bank_account: cc_account) if i == 5
        remember_payment(payment2)

        # Create payment from market to seller
        payment = create(:payment,
                         payment_method: ["cash", "check"][i % 2],
                         payer: @market,
                         payee: @seller,
                         orders: [@orders[i]],
                         note: ["", "#67890"][i % 2],
                         amount: @orders[i].total_cost)
        remember_payment(payment)

        # Create payment from market to seller2
        create(:payment,
               payment_method: ["cash", "check"][i % 2],
               payer: @market2,
               payee: @seller2,
               orders: [@orders2[i]],
               note: ["", "#54321"][i % 2],
               amount: @orders2[i].total_cost)
        remember_payment(payment)
      end
    end

    # Multiple market payments
    Timecop.freeze(@payment_day - 1.day) do
      # Create a fee for market
      create(:payment,
             payment_method: "ach",
             payment_type: "service",
             payer: @market,
             payee: nil,
             amount: 99.00)

      # Create a cash buyer payment for a market that IS managed by our market manager
      order = create(:order,
                     delivery: @delivery,
                     items: [create(:order_item, unit_price: 123.00, quantity: 1)],
                     organization: @buyer2,
                     market: @market2,
                     payment_method: "purchase order",
                     payment_status: "paid",
                     order_number: "LO-02-234-4567890-123",
                     total_cost: 123.00)
      payment = create(:payment,
                       payment_method: "cash",
                       payer: @buyer2,
                       payee: @market2,
                       orders: [order],
                       amount: order.total_cost)
      remember_payment(payment)

      # Create a cash buyer payment for a market that IS NOT managed by our market manager
      order = create(:order,
                     delivery: @delivery,
                     items: [create(:order_item, unit_price: 234.00, quantity: 1)],
                     organization: @buyer2,
                     market: market3,
                     payment_method: "purchase order",
                     payment_status: "paid",
                     order_number: "LO-02-234-4567890-234",
                     total_cost: 234.00)
      payment = create(:payment,
                       payment_method: "cash",
                       payer: @buyer2,
                       payee: market3,
                       orders: [order],
                       amount: order.total_cost)
      remember_payment(payment)

      # Create an ACH buyer payment for a market that IS managed by our market manager
      order = create(:order,
                     delivery: @delivery,
                     items: [create(:order_item, unit_price: 345.00, quantity: 1)],
                     organization: @buyer2,
                     market: @market2,
                     payment_method: "ach",
                     payment_status: "paid",
                     order_number: "LO-02-234-4567890-345",
                     total_cost: 345.00)
      payment = create(:payment,
                       payment_method: "ach",
                       payer: @buyer2,
                       payee: nil,
                       orders: [order],
                       amount: order.total_cost,
                       bank_account: ach_account)
      remember_payment(payment)

      payment = create(:payment,
                       payment_method: "ach",
                       payment_type: "order refund",
                       payer: @buyer2,
                       payee: nil,
                       orders: [order],
                       amount: -22.34,
                       bank_account: ach_account)
      remember_payment(payment)



      # Create an ACH buyer payment for a market that IS NOT managed by our market manager
      order = create(:order,
                     delivery: @delivery,
                     items: [create(:order_item, unit_price: 456.00, quantity: 1)],
                     organization: @buyer2,
                     market: market3,
                     payment_method: "ach",
                     payment_status: "paid",
                     order_number: "LO-02-234-4567890-456",
                     total_cost: 456.00)
      payment = create(:payment,
                       payment_method: "ach",
                       payer: @buyer2,
                       payee: nil,
                       orders: [order],
                       amount: order.total_cost,
                       bank_account: other_ach_account)
      remember_payment(payment)

      # Create Local Orbit -> Seller payment
      order = create(:order,
                     delivery: @delivery,
                     items: [create(:order_item, unit_price: 888.00, quantity: 1)],
                     organization: @buyer,
                     market: @market,
                     payment_method: "ach",
                     payment_status: "paid",
                     order_number: "LO-02-234-4567890-888",
                     total_cost: 888.00)
      payment = create(:payment,
                       payment_method: "ach",
                       payer: nil,
                       payee: @seller,
                       orders: [order],
                       amount: order.total_cost,
                       bank_account: other_ach_account)
      remember_payment(payment)

      # Create Market -> Seller payment
      order = create(:order,
                     delivery: @delivery,
                     items: [create(:order_item, unit_price: 999.00, quantity: 1)],
                     organization: @buyer,
                     market: @market,
                     payment_method: "check",
                     payment_status: "paid",
                     order_number: "LO-02-234-4567890-999",
                     total_cost: 999.00)
      payment = create(:payment,
                       payment_type: "seller payment",
                       payment_method: "check",
                       payer: @market,
                       payee: @seller,
                       orders: [order],
                       amount: order.total_cost,
                       bank_account: other_ach_account)
      remember_payment(payment)
    end
  end

  before do
    switch_to_subdomain(@market.subdomain)
    sign_in_as(user)

    click_link "Financials"
    click_link "Review Payment History"
    visit "/admin/financials/payments?per_page=50"
    expect(page).to have_content("Payment History")
  end

  def payment_row(amount)
    Dom::Admin::Financials::PaymentRow.find_by_amount(amount)
  end

  def payment_rows_for_description(description)
    Dom::Admin::Financials::PaymentRow.all.select {|row| row.description == "Order #: #{description}" }
  end

  context "Any User" do
    let!(:user) { create(:user, organizations: [@buyer]) }

    before do
      within("table thead") do
        expect(page).to have_content("Payment Date")
        expect(page).to have_content("Description")
        expect(page).to have_content("Payment Method")
        expect(page).to have_content("Amount")
        expect(page).not_to have_content("Received From")
        expect(page).not_to have_content("Paid To")
      end
    end

    scenario "default sort order payment date descending" do
      payments = Dom::Admin::Financials::PaymentRow.all

      # Default sort order should be payment date descending
      expect(payments.count).to eq(5)
      expect(payments[0].date).to eq(format_date(@payment_day + 5.days))
      expect(payments[1].date).to eq(format_date(@payment_day + 4.days))
      expect(payments[2].date).to eq(format_date(@payment_day + 3.days))
      expect(payments[3].date).to eq(format_date(@payment_day + 2.days))
      expect(payments[4].date).to eq(format_date(@payment_day + 1.day))

    end

    scenario "can sort by payment date" do
      click_link "Payment Date"

      payments = Dom::Admin::Financials::PaymentRow.all

      expect(payments.count).to eq(5)
      expect(payments[0].date).to eq(format_date(@payment_day + 1.day))
      expect(payments[1].date).to eq(format_date(@payment_day + 2.days))
      expect(payments[2].date).to eq(format_date(@payment_day + 3.days))
      expect(payments[3].date).to eq(format_date(@payment_day + 4.days))
      expect(payments[4].date).to eq(format_date(@payment_day + 5.days))
    end

    scenario "can sort by payment amount" do
      click_link "Amount"

      payments = Dom::Admin::Financials::PaymentRow.all

      expect(payments.count).to eq(5)
      expect(payments[0].amount).to eq("$21.00")
      expect(payments[1].amount).to eq("$22.00")
      expect(payments[2].amount).to eq("$23.00")
      expect(payments[3].amount).to eq("$24.00")
      expect(payments[4].amount).to eq("$25.00")

      click_link "Amount"

      payments = Dom::Admin::Financials::PaymentRow.all

      expect(payments.count).to eq(5)
      expect(payments[0].amount).to eq("$25.00")
      expect(payments[1].amount).to eq("$24.00")
      expect(payments[2].amount).to eq("$23.00")
      expect(payments[3].amount).to eq("$22.00")
      expect(payments[4].amount).to eq("$21.00")
    end

    scenario "can download a CSV of payment history" do
      payments = Dom::Admin::Financials::PaymentRow.all
      html_headers = page.all("th").map(&:text)

      expect(payments.count).to eq(5)

      click_link "Export CSV"

      csv = CSV.parse(page.body, headers: true)

      expect(csv.count).to eq(5)

      # Ensure we see the same columns in HTML and CSV
      expect(csv.headers).to eql(html_headers << "Order Numbers")

      payments.each_with_index do |payment, i|
        expect(csv[i]["Payment Date"]).to eq(payment.date)
        expect(csv[i]["Description"]).to eq(payment.description)
        expect(csv[i]["Payment Method"]).to eq(payment.payment_method)
        expect(csv[i]["Amount"]).to eq(payment.amount)
        expect(csv[i]["Order Numbers"]).to eql(@payments[payment.date])
      end
    end

    context "viewing orders by payment type" do
      let!(:order) do
        order_item = create(:order_item, unit_price: 12.34, quantity: 1)
        create(:order,
               delivery: @delivery,
               items: [order_item],
               organization: @buyer,
               payment_method: "ach",
               payment_status: "paid",
               order_number: "LO-99-234-4567890-1234")
      end

      before do
        # order
        create(:payment,
               payment_type: "order",
               payment_method: "ach",
               payer: @buyer,
               payee: @market,
               orders: [order],
               amount: 12.34)

        # order refund
        create(:payment,
               payment_type: "order refund",
               payment_method: "ach",
               payer: @buyer,
               payee: @market,
               orders: [order],
               amount: -23.45)

        # seller payment
        create(:payment,
               payment_type: "seller payment",
               payment_method: "ach",
               payer: @buyer,
               payee: @market,
               orders: [order],
               amount: 34.56)

        # market payment
        create(:payment,
               payment_type: "market payment",
               payment_method: "ach",
               payer: @buyer,
               payee: @market,
               orders: [order],
               amount: 45.67)

        # service fee
        create(:payment,
               payment_type: "service",
               payment_method: "ach",
               payer: @buyer,
               payee: @market,
               orders: [order],
               amount: 56.78)

        click_link "Financials"
        click_link "Review Payment History"
      end

      it "sees the correct order for each payment type" do
        expect(payment_row("$12.34").description).to eq("Order #: LO-99-234-4567890-1234")
        expect(payment_row("$23.45").description).to eq("Order Refund #: LO-99-234-4567890-1234")
        expect(payment_row("$34.56").description).to eq("Order #: LO-99-234-4567890-1234")
        expect(payment_row("$45.67").description).to eq("Order #: LO-99-234-4567890-1234")
        expect(payment_row("$56.78").description).to eq("Service Fee")
      end


    end
  end

  context "Market Managers" do
    let!(:user) { create(:user, :market_manager, managed_markets: [@market, @market2]) }

    # 5 buyer   -> market payments
    # 5 @buyer2  -> market2 payments
    # 5 seller  -> market payments
    # 5 seller2 -> market2 payments
    # 1 market -> seller payment
    # 1 Local Orbit -> seller payment
    # 1 cash buyer payment
    # 1 ACH buyer payment
    # 1 service fee

    scenario "can view their purchase history" do
      within("table thead") do
        expect(page).to have_content("Payment Date")
        expect(page).to have_content("Description")
        expect(page).to have_content("Payment Method")
        expect(page).to have_content("Received From")
        expect(page).to have_content("Paid To")
        expect(page).to have_content("Amount")
      end

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(26)

      expect(payment_rows_for_description("LO-01-234-4567890-1").count).to eq(2)
      expect(payment_rows_for_description("LO-01-234-4567890-2").count).to eq(2)
      expect(payment_rows_for_description("LO-01-234-4567890-3").count).to eq(2)
      expect(payment_rows_for_description("LO-01-234-4567890-4").count).to eq(2)
      expect(payment_rows_for_description("LO-01-234-4567890-5").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-1").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-2").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-3").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-4").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-5").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-123").count).to eq(1)
      expect(payment_rows_for_description("LO-02-234-4567890-345").count).to eq(1)
      expect(payment_rows_for_description("LO-02-234-4567890-888").count).to eq(1)
      expect(payment_rows_for_description("LO-02-234-4567890-999").count).to eq(1)
      expect(Dom::Admin::Financials::PaymentRow.find_by_description("Service Fee")).not_to be_nil
    end

    scenario "can view buyer order payments for markets they manage" do
      # 5 buyer   -> market payments
      # 5 @buyer2  -> market2 payments
      # 5 seller  -> market payments
      # 5 seller2 -> market2 payments
      # 1 market -> seller payment
      # 1 Local Orbit -> seller payment
      # 1 cash buyer payment
      # 1 ACH buyer payment
      # 1 service fee

      expect(payment_row("$123.00")).not_to be_nil
      expect(payment_row("$123.00").payment_method).to eql("Cash")
      expect(payment_row("$123.00").date).to eql(format_date(@payment_day - 1.day))
      expect(payment_row("$123.00").from).to eql(@buyer2.name)
      expect(payment_row("$123.00").to).to eql(@market2.name)

      expect(payment_row("$345.00")).not_to be_nil
      expect(payment_row("$345.00").payment_method).to eql("ACH: *********9983")
      expect(payment_row("$345.00").date).to eql(format_date(@payment_day - 1.day))
      expect(payment_row("$345.00").from).to eql(@buyer2.name)
      expect(payment_row("$345.00").to).to eql("Local Orbit")

      expect(payment_row("$22.34")).not_to be_nil
      expect(payment_row("$22.34").payment_method).to eql("ACH: *********9983")
      expect(payment_row("$22.34").date).to eql(format_date(@payment_day - 1.day))
      expect(payment_row("$22.34").to).to eql(@buyer2.name)
      expect(payment_row("$22.34").from).to eql("Local Orbit")
    end

    scenario "can view fews for markets they manage" do
      expect(payment_row("$99.00")).not_to be_nil
      expect(payment_row("$99.00").payment_method).to eql("ACH")
      expect(payment_row("$99.00").date).to eql(format_date(@payment_day - 1.day))
    end

    scenario "cannot view buyer order payments for markets they do not manage" do
      expect(payment_row("$234.00")).to be_nil
      expect(payment_row("$456.00")).to be_nil
    end

    scenario "can search purchase history by order number" do
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(26)

      fill_in "Search Payments", with: "4567890-1"
      click_button "Search"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(5)
      expect(payment_rows_for_description("LO-01-234-4567890-1").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-1").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-123").count).to eq(1)
    end

    scenario "can search purchase history by payer or payee name" do
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(26)

      fill_in "Search Payments", with: "Buyer 2"
      click_button "Search"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(8)
      expect(payment_rows_for_description("LO-02-234-4567890-1").count).to eq(1)
      expect(payment_rows_for_description("LO-02-234-4567890-2").count).to eq(1)
      expect(payment_rows_for_description("LO-02-234-4567890-3").count).to eq(1)
      expect(payment_rows_for_description("LO-02-234-4567890-4").count).to eq(1)
      expect(payment_rows_for_description("LO-02-234-4567890-5").count).to eq(1)
      expect(payment_rows_for_description("LO-02-234-4567890-123").count).to eq(1)
      expect(payment_rows_for_description("LO-02-234-4567890-345").count).to eq(1)

      fill_in "Search Payments", with: "Seller 2"
      click_button "Search"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(5)
      expect(payment_rows_for_description("LO-02-234-4567890-1").count).to eq(1)
      expect(payment_rows_for_description("LO-02-234-4567890-2").count).to eq(1)
      expect(payment_rows_for_description("LO-02-234-4567890-3").count).to eq(1)
      expect(payment_rows_for_description("LO-02-234-4567890-4").count).to eq(1)
      expect(payment_rows_for_description("LO-02-234-4567890-5").count).to eq(1)
    end

    scenario "can filter purchase history by payment date" do
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(26)

      fill_in "q_created_at_date_gteq", with: (@payment_day + 2.days).to_s
      click_button "Filter"
      get_results(20)
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(16)
      expect(payment_rows_for_description("LO-01-234-4567890-2").count).to eq(2)
      expect(payment_rows_for_description("LO-01-234-4567890-3").count).to eq(2)
      expect(payment_rows_for_description("LO-01-234-4567890-4").count).to eq(2)
      expect(payment_rows_for_description("LO-01-234-4567890-5").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-2").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-3").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-4").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-5").count).to eq(2)

      fill_in "q_created_at_date_lteq", with: (@payment_day + 3.days).to_s
      click_button "Filter"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(8)
      expect(payment_rows_for_description("LO-01-234-4567890-2").count).to eq(2)
      expect(payment_rows_for_description("LO-01-234-4567890-3").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-2").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-3").count).to eq(2)
    end

    scenario "can filter purchase history by payment method" do
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(26)

      select "ACH", from: "Payment Method", visible: false
      click_button "Filter"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(8)
      expect(payment_row("$23.00")).not_to be_nil
      expect(payment_row("$23.01")).not_to be_nil
      expect(payment_row("$24.00")).not_to be_nil
      expect(payment_row("$24.01")).not_to be_nil
      expect(payment_row("$99.00")).not_to be_nil
      expect(payment_row("$345.00")).not_to be_nil

      unselect "ACH", from: "Payment Method", visible: false
      click_button "Filter"

    end

    scenario "can filter purchase history by payment type" do
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(26)

      select "Order", from: "Payment Type", visible: false
      click_button "Filter"
      get_results(30)

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(23)
      unselect "Order", from: "Payment Type", visible: false
      click_button "Filter"

      select "Service Fee", from: "Payment Type", visible: false
      click_button "Filter"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(1)
      unselect "Service Fee", from: "Payment Type", visible: false
      click_button "Filter"

    end

    scenario "can filter purchase history by payer" do
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(26)

      select @market.name, from: "Received From", visible: false
      click_button "Filter"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(7)
      unselect @market.name, from: "Received From", visible: false
      click_button "Filter"

      select "Buyer", from: "Received From", visible: false
      click_button "Filter"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(5)
      unselect "Buyer", from: "Received From", visible: false
      click_button "Filter"

    end

    scenario "can filter purchase history by payee" do
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(26)

      select @market.name, from: "Paid To", visible: false
      click_button "Filter"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(5)
      unselect @market.name, from: "Paid To", visible: false
      click_button "Filter"

      select @seller.name, from: "Paid To", visible: false
      click_button "Filter"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(7)
      unselect @seller.name, from: "Paid To", visible: false
      click_button "Filter"

      select @market2.name, from: "Paid To", visible: false
      click_button "Filter"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(6)
      unselect @market2.name, from: "Paid To", visible: false
      click_button "Filter"

      #select "Local Orbit", from: "Paid To", visible: false
      #click_button "Filter"

      # Service Fee + ACH Buyer Payment
      #expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(3)
      #unselect "Local Orbit", from: "Paid To", visible: false
      #click_button "Filter"

    end

    # https://www.pivotaltracker.com/story/show/78823306
    scenario "can click on an Order # to view the Order" do
      follow_admin_order_link order: @orders[2]
    end

    context "who have only one market" do
      let!(:user) { create(:user, :market_manager, managed_markets: [@market]) }

      scenario "will not see an option to filter by market" do
        expect(page).not_to have_select("Received From")
      end
    end
  end

  context "Buyers" do
    let!(:user) { create(:user, organizations: [@buyer]) }
    let!(:market_manager) { create(:user, managed_markets: [@market]) }

    scenario "can view their purchase history" do
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(5)

      expect(payment_row("$21.00")).not_to be_nil
      expect(payment_row("$21.00").payment_method).to eql("Cash")
      expect(payment_row("$21.00").date).to eql(format_date(@payment_day + 1.day))

      expect(payment_row("$22.00")).not_to be_nil
      expect(payment_row("$22.00").payment_method).to eql("Check: #12345")
      expect(payment_row("$22.00").date).to eql(format_date(@payment_day + 2.days))

      expect(payment_row("$23.00")).not_to be_nil
      expect(payment_row("$23.00").payment_method).to eql("ACH: *********9983")
      expect(payment_row("$23.00").date).to eql(format_date(@payment_day + 3.days))

      expect(payment_row("$24.00")).not_to be_nil
      expect(payment_row("$24.00").payment_method).to eql("ACH: *********2231")
      expect(payment_row("$24.00").date).to eql(format_date(@payment_day + 4.days))

      expect(payment_row("$25.00")).not_to be_nil
      expect(payment_row("$25.00").payment_method).to eql("Credit Card: ************7732")
      expect(payment_row("$25.00").date).to eql(format_date(@payment_day + 5.days))
    end

    # https://www.pivotaltracker.com/story/show/78823306
    scenario "can click on an Order # to view the Order" do
      follow_buyer_order_link order: @orders[5]
    end

    scenario "can view their purchase history after market manage deletes an organization" do
      switch_user(market_manager) do
        delete_organization(@seller)
      end

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(5)

      expect(payment_row("$21.00")).not_to be_nil
      expect(payment_row("$21.00").payment_method).to eql("Cash")
      expect(payment_row("$21.00").date).to eql(format_date(@payment_day + 1.day))

      expect(payment_row("$22.00")).not_to be_nil
      expect(payment_row("$22.00").payment_method).to eql("Check: #12345")
      expect(payment_row("$22.00").date).to eql(format_date(@payment_day + 2.days))

      expect(payment_row("$23.00")).not_to be_nil
      expect(payment_row("$23.00").payment_method).to eql("ACH: *********9983")
      expect(payment_row("$23.00").date).to eql(format_date(@payment_day + 3.days))

      expect(payment_row("$24.00")).not_to be_nil
      expect(payment_row("$24.00").payment_method).to eql("ACH: *********2231")
      expect(payment_row("$24.00").date).to eql(format_date(@payment_day + 4.days))

      expect(payment_row("$25.00")).not_to be_nil
      expect(payment_row("$25.00").payment_method).to eql("Credit Card: ************7732")
      expect(payment_row("$25.00").date).to eql(format_date(@payment_day + 5.days))
    end

    scenario "cannot view market-to-seller payments" do
      expect(payment_rows_for_description("LO-01-234-4567890-1").count).to eq(1)
      expect(payment_rows_for_description("LO-01-234-4567890-2").count).to eq(1)
      expect(payment_rows_for_description("LO-01-234-4567890-3").count).to eq(1)
      expect(payment_rows_for_description("LO-01-234-4567890-4").count).to eq(1)
      expect(payment_rows_for_description("LO-01-234-4567890-5").count).to eq(1)
    end

    scenario "can search purchase history by order number" do
      expect(payment_row("$21.00").description).to include("LO-01-234-4567890-1")
      expect(payment_row("$22.00").description).to include("LO-01-234-4567890-2")
      expect(payment_row("$23.00").description).to include("LO-01-234-4567890-3")
      expect(payment_row("$24.00").description).to include("LO-01-234-4567890-4")
      expect(payment_row("$25.00").description).to include("LO-01-234-4567890-5")

      fill_in "Search Payments", with: "4567890-1"
      click_button "Search"

      expect(page).to     have_content("LO-01-234-4567890-1")
      expect(page).not_to have_content("LO-01-234-4567890-2")
      expect(page).not_to have_content("LO-01-234-4567890-3")
      expect(page).not_to have_content("LO-01-234-4567890-4")
      expect(page).not_to have_content("LO-01-234-4567890-5")
    end

    scenario "can filter purchase history by payment date" do
      expect(payment_row("$21.00").description).to include("LO-01-234-4567890-1")
      expect(payment_row("$22.00").description).to include("LO-01-234-4567890-2")
      expect(payment_row("$23.00").description).to include("LO-01-234-4567890-3")
      expect(payment_row("$24.00").description).to include("LO-01-234-4567890-4")
      expect(payment_row("$25.00").description).to include("LO-01-234-4567890-5")

      fill_in "q_created_at_date_gteq", with: (@payment_day + 2.days).to_s
      click_button "Filter"

      expect(page).not_to have_content("LO-01-234-4567890-1")
      expect(page).to     have_content("LO-01-234-4567890-2")
      expect(page).to     have_content("LO-01-234-4567890-3")
      expect(page).to     have_content("LO-01-234-4567890-4")
      expect(page).to     have_content("LO-01-234-4567890-5")

      fill_in "q_created_at_date_lteq", with: (@payment_day + 3.days).to_s
      click_button "Filter"

      expect(page).not_to have_content("LO-01-234-4567890-1")
      expect(page).to     have_content("LO-01-234-4567890-2")
      expect(page).to     have_content("LO-01-234-4567890-3")
      expect(page).not_to have_content("LO-01-234-4567890-4")
      expect(page).not_to have_content("LO-01-234-4567890-5")
    end

    context "user belongs to multiple organizations" do
      let!(:buyer3) { create(:organization, :buyer, name: "Buyer 3", markets: [@market]) }
      let!(:user)   { create(:user, organizations: [@buyer, buyer3]) }

      scenario "cannot view purchases in an organization they've been suspended from", :suspend_user do
        # suspend the user
        suspend_user(user: user, org: @buyer)

        click_link "Financials"
        click_link "Review Payment History"

        expect(page).to have_content("Payment History")
        expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(0)
      end
    end
  end

  context "Sellers" do
    let!(:user) { create(:user, organizations: [@seller]) }

    scenario "can view their payment history" do
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(7)

      expect(payment_row("$21.00")).not_to be_nil
      expect(payment_row("$21.00").payment_method).to eql("Check: #67890")
      expect(payment_row("$21.00").date).to eql(format_date(@payment_day + 1.day))

      expect(payment_row("$22.00")).not_to be_nil
      expect(payment_row("$22.00").payment_method).to eql("Cash")
      expect(payment_row("$22.00").date).to eql(format_date(@payment_day + 2.days))

      expect(payment_row("$23.00")).not_to be_nil
      expect(payment_row("$23.00").payment_method).to eql("Check: #67890")
      expect(payment_row("$23.00").date).to eql(format_date(@payment_day + 3.days))

      expect(payment_row("$24.00")).not_to be_nil
      expect(payment_row("$24.00").payment_method).to eql("Cash")
      expect(payment_row("$24.00").date).to eql(format_date(@payment_day + 4.days))

      expect(payment_row("$25.00")).not_to be_nil
      expect(payment_row("$25.00").payment_method).to eql("Check: #67890")
      expect(payment_row("$25.00").date).to eql(format_date(@payment_day + 5.days))

      expect(payment_row("$888.00")).not_to be_nil
      expect(payment_row("$888.00").payment_method).to eql("ACH: *********2231")
      expect(payment_row("$888.00").date).to eql(format_date(@payment_day - 1.day))

      expect(payment_row("$999.00")).not_to be_nil
      expect(payment_row("$999.00").payment_method).to eql("Check")
      expect(payment_row("$999.00").date).to eql(format_date(@payment_day - 1.day))
    end

    scenario "can search purchase history by order number" do
      expect(payment_row("$21.00").description).to include("LO-01-234-4567890-1")
      expect(payment_row("$22.00").description).to include("LO-01-234-4567890-2")
      expect(payment_row("$23.00").description).to include("LO-01-234-4567890-3")
      expect(payment_row("$24.00").description).to include("LO-01-234-4567890-4")
      expect(payment_row("$25.00").description).to include("LO-01-234-4567890-5")
      expect(payment_row("$888.00").description).to include("LO-02-234-4567890-888")
      expect(payment_row("$999.00").description).to include("LO-02-234-4567890-999")

      fill_in "Search Payments", with: "4567890-1"
      click_button "Search"

      expect(page).to have_content("LO-01-234-4567890-1")
      expect(page).not_to have_content("LO-01-234-4567890-2")
      expect(page).not_to have_content("LO-01-234-4567890-3")
      expect(page).not_to have_content("LO-01-234-4567890-4")
      expect(page).not_to have_content("LO-01-234-4567890-5")
    end

    scenario "can filter purchase history by payment date" do
      expect(payment_row("$21.00").description).to include("LO-01-234-4567890-1")
      expect(payment_row("$22.00").description).to include("LO-01-234-4567890-2")
      expect(payment_row("$23.00").description).to include("LO-01-234-4567890-3")
      expect(payment_row("$24.00").description).to include("LO-01-234-4567890-4")
      expect(payment_row("$25.00").description).to include("LO-01-234-4567890-5")
      expect(payment_row("$888.00").description).to include("LO-02-234-4567890-888")
      expect(payment_row("$999.00").description).to include("LO-02-234-4567890-999")

      fill_in "q_created_at_date_gteq", with: (@payment_day + 2.days).to_s
      click_button "Filter"

      expect(page).not_to have_content("LO-01-234-4567890-1")
      expect(page).to have_content("LO-01-234-4567890-2")
      expect(page).to have_content("LO-01-234-4567890-3")
      expect(page).to have_content("LO-01-234-4567890-4")
      expect(page).to have_content("LO-01-234-4567890-5")

      fill_in "q_created_at_date_lteq", with: (@payment_day + 3.days).to_s
      click_button "Filter"

      expect(page).not_to have_content("LO-01-234-4567890-1")
      expect(page).to have_content("LO-01-234-4567890-2")
      expect(page).to have_content("LO-01-234-4567890-3")
      expect(page).not_to have_content("LO-01-234-4567890-4")
      expect(page).not_to have_content("LO-01-234-4567890-5")
    end

    scenario "can filter purchase history by payment method" do
      expect(payment_row("$21.00").description).to include("LO-01-234-4567890-1")
      expect(payment_row("$22.00").description).to include("LO-01-234-4567890-2")
      expect(payment_row("$23.00").description).to include("LO-01-234-4567890-3")
      expect(payment_row("$24.00").description).to include("LO-01-234-4567890-4")
      expect(payment_row("$25.00").description).to include("LO-01-234-4567890-5")
      expect(payment_row("$888.00").description).to include("LO-02-234-4567890-888")
      expect(payment_row("$999.00").description).to include("LO-02-234-4567890-999")

      select "Check", from: "Payment Method", visible: false
      click_button "Filter"

      expect(page).to have_content("LO-01-234-4567890-1")
      expect(page).not_to have_content("LO-01-234-4567890-2")
      expect(page).to have_content("LO-01-234-4567890-3")
      expect(page).not_to have_content("LO-01-234-4567890-4")
      expect(page).to have_content("LO-01-234-4567890-5")
      unselect "Check", from: "Payment Method", visible: false

      select "Cash", from: "Payment Method", visible: false
      click_button "Filter"

      expect(page).not_to have_content("LO-01-234-4567890-1")
      expect(page).to have_content("LO-01-234-4567890-2")
      expect(page).not_to have_content("LO-01-234-4567890-3")
      expect(page).to have_content("LO-01-234-4567890-4")
      expect(page).not_to have_content("LO-01-234-4567890-5")
      unselect "Cash", from: "Payment Method", visible: false

    end

    # https://www.pivotaltracker.com/story/show/78823306
    scenario "can click on an Order # to view the Order" do
      follow_admin_order_link order: @orders[1]
    end
  end
end
