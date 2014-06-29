require "spec_helper"

feature "Payment history", :truncate_after_all do
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

    @buyer  = create(:organization, :buyer,  name: "Buyer",    markets: [@market])
    @buyer2  = create(:organization, :buyer,  name: "Buyer 2",  markets: [@market2, market3])
    @seller = create(:organization, :seller, name: "Seller",   markets: [@market])
    @seller2 = create(:organization, :seller, name: "Seller 2", markets: [@market2])

    payment_day = DateTime.parse("May 9, 2014, 11:00:00")

    ach_account       = create(:bank_account, :checking,    last_four: "9983", balanced_uri: ach_balanced_uri,       bankable: @buyer)
    other_ach_account = create(:bank_account, :checking,    last_four: "2231", balanced_uri: other_ach_balanced_uri, bankable: @buyer)
    cc_account        = create(:bank_account, :credit_card, last_four: "7732", balanced_uri: cc_balanced_uri,        bankable: @buyer)

    order_item = create(:order_item, unit_price: 6.50, quantity: 2)
    create(:order, delivery: @delivery, items: [order_item], organization: @buyer, payment_method: "purchase order", total_cost: 13.00)

    order_item = create(:order_item, unit_price: 36.00, quantity: 2)
    create(:order, delivery: @delivery, items: [order_item], organization: @buyer, payment_method: "ach", total_cost: 72.00)

    order_item = create(:order_item, unit_price: 129.00, quantity: 1)
    create(:order, delivery: @delivery, items: [order_item], organization: @buyer, payment_method: "credit card", total_cost: 129.00)

    orders = []
    orders2 = []
    6.times do |i|
      order_item = create(:order_item, unit_price: 20.00 + i, quantity: 1)
      orders << create(:order,
                       delivery: @delivery,
                       items: [order_item],
                       organization: @buyer,
                       payment_method: ["purchase order", "purchase order", "purchase order", "ach", "ach", "credit card"][i],
                       payment_status: "paid",
                       order_number: "LO-01-234-4567890-#{i}")
      orders2 << create(:order,
                       delivery: @delivery,
                       items: [order_item],
                       organization: @buyer2,
                       payment_method: ["purchase order", "purchase order", "purchase order", "ach", "ach", "credit card"][i],
                       payment_status: "paid",
                       order_number: "LO-02-234-4567890-#{i}")
    end

    (1..5).each do |i|
      Timecop.freeze(payment_day + i.days) do
        # Create payment from buyer to market
        payment = create(:payment,
                         payment_method: ["cash", "check", "ach", "ach", "credit card"][i - 1],
                         payer: @buyer,
                         payee: @market,
                         orders: [orders[i]],
                         amount: orders[i].total_cost)

        payment.update_attribute(:note, "#12345") if i == 2
        payment.update_attributes(bank_account: ach_account) if i == 3
        payment.update_attributes(bank_account: other_ach_account, status: "pending") if i == 4
        payment.update_attributes(bank_account: cc_account) if i == 5

        payment2 = create(:payment,
                         payment_method: ["cash", "check", "ach", "ach", "credit card"][i - 1],
                         payer: @buyer2,
                         payee: @market2,
                         orders: [orders2[i]],
                         amount: orders2[i].total_cost + 0.01)

        payment2.update_attribute(:note, "#12345") if i == 2
        payment2.update_attributes(bank_account: ach_account) if i == 3
        payment2.update_attributes(bank_account: other_ach_account, status: "pending") if i == 4
        payment2.update_attributes(bank_account: cc_account) if i == 5

        # Create payment from market to seller
        create(:payment,
               payment_method: ["cash", "check"][i % 2],
               payer: @market,
               payee: @seller,
               orders: [orders[i]],
               note: ["", "#67890"][i % 2],
               amount: orders[i].total_cost * 2)

        # Create payment from market to seller2
        create(:payment,
               payment_method: ["cash", "check"][i % 2],
               payer: @market2,
               payee: @seller2,
               orders: [orders2[i]],
               note: ["", "#54321"][i % 2],
               amount: orders2[i].total_cost * 2)
      end
    end

    # Multiple market payments
    Timecop.freeze(payment_day - 1.day) do
      # Create a fee for market
      create(:payment,
             payment_method: 'ach',
             payment_type: 'service',
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
                    order_number: "LO-02-234-4567890-123")
      create(:payment,
            payment_method: "cash",
            payer: @buyer2,
            payee: @market2,
            orders: [order],
            amount: order.total_cost)

      # Create a cash buyer payment for a market that IS NOT managed by our market manager
      order = create(:order,
                    delivery: @delivery,
                    items: [create(:order_item, unit_price: 234.00, quantity: 1)],
                    organization: @buyer2,
                    market: market3,
                    payment_method: "purchase order",
                    payment_status: "paid",
                    order_number: "LO-02-234-4567890-234")
      create(:payment,
            payment_method: "cash",
            payer: @buyer2,
            payee: market3,
            orders: [order],
            amount: order.total_cost)

      # Create an ACH buyer payment for a market that IS managed by our market manager
      order = create(:order,
                    delivery: @delivery,
                    items: [create(:order_item, unit_price: 345.00, quantity: 1)],
                    organization: @buyer2,
                    market: @market2,
                    payment_method: "ach",
                    payment_status: "paid",
                    order_number: "LO-02-234-4567890-345")
      create(:payment,
            payment_method: "ach",
            payer: @buyer2,
            payee: nil,
            orders: [order],
            amount: order.total_cost,
            bank_account: ach_account)

      # Create an ACH buyer payment for a market that IS NOT managed by our market manager
      order = create(:order,
                    delivery: @delivery,
                    items: [create(:order_item, unit_price: 456.00, quantity: 1)],
                    organization: @buyer2,
                    market: market3,
                    payment_method: "ach",
                    payment_status: "paid",
                    order_number: "LO-02-234-4567890-456")
      create(:payment,
            payment_method: "ach",
            payer: @buyer2,
            payee: nil,
            orders: [order],
            amount: order.total_cost,
            bank_account: other_ach_account)

      # Create Local Orbit -> Seller payment
      order = create(:order,
                    delivery: @delivery,
                    items: [create(:order_item, unit_price: 888.00, quantity: 1)],
                    organization: @buyer,
                    market: @market,
                    payment_method: "ach",
                    payment_status: "paid",
                    order_number: "LO-02-234-4567890-888")
      create(:payment,
            payment_method: "ach",
            payer: nil,
            payee: @seller,
            orders: [order],
            amount: order.total_cost,
            bank_account: other_ach_account)

      # Create Market -> Seller payment
      order = create(:order,
                    delivery: @delivery,
                    items: [create(:order_item, unit_price: 999.00, quantity: 1)],
                    organization: @buyer,
                    market: @market,
                    payment_method: "check",
                    payment_status: "paid",
                    order_number: "LO-02-234-4567890-999")
      create(:payment,
            payment_type: "seller payment",
            payment_method: "check",
            payer: @market,
            payee: @seller,
            orders: [order],
            amount: order.total_cost,
            bank_account: other_ach_account)
    end
  end

  before do
    switch_to_subdomain(@market.subdomain)
    sign_in_as(user)

    click_link "Financials"
    click_link "Review Payment History"

    expect(page).to have_content("Payment History")
  end

  def payment_row(amount)
    Dom::Admin::Financials::PaymentRow.find_by_amount(amount)
  end

  def payment_rows_for_description(description)
    Dom::Admin::Financials::PaymentRow.all.select { |row| row.description == "Order #: #{description}" }
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

      payments = Dom::Admin::Financials::PaymentRow.all

      # Default sort order should be payment date descending
      expect(payments.count).to eq(5)
      expect(payments[0].date).to eq("05/14/2014")
      expect(payments[1].date).to eq("05/13/2014")
      expect(payments[2].date).to eq("05/12/2014")
      expect(payments[3].date).to eq("05/11/2014")
      expect(payments[4].date).to eq("05/10/2014")

    end

    scenario "can sort by payment date" do
      click_link "Payment Date"

      payments = Dom::Admin::Financials::PaymentRow.all

      expect(payments.count).to eq(5)
      expect(payments[0].date).to eq("05/10/2014")
      expect(payments[1].date).to eq("05/11/2014")
      expect(payments[2].date).to eq("05/12/2014")
      expect(payments[3].date).to eq("05/13/2014")
      expect(payments[4].date).to eq("05/14/2014")
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
      expect(csv.headers).to eq(html_headers)

      payments.each_with_index do |payment, i|
        expect(csv[i]["Payment Date"]).to eq(payment.date)
        expect(csv[i]["Description"]).to eq(payment.description)
        expect(csv[i]["Payment Method"]).to eq(payment.payment_method)
        expect(csv[i]["Amount"]).to eq(payment.amount)
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
               amount: 23.45)

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

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(25)

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
      expect(payment_row("$123.00").date).to eql("05/08/2014")
      expect(payment_row("$123.00").from).to eql(@buyer2.name)
      expect(payment_row("$123.00").to).to eql(@market2.name)

      expect(payment_row("$345.00")).not_to be_nil
      expect(payment_row("$345.00").payment_method).to eql("ACH: *********9983")
      expect(payment_row("$345.00").date).to eql("05/08/2014")
      expect(payment_row("$345.00").from).to eql(@buyer2.name)
      expect(payment_row("$345.00").to).to eql("Local Orbit")
    end

    scenario "can view fews for markets they manage" do
      expect(payment_row("$99.00")).not_to be_nil
      expect(payment_row("$99.00").payment_method).to eql("ACH")
      expect(payment_row("$99.00").date).to eql("05/08/2014")
    end

    scenario "cannot view buyer order payments for markets they do not manage" do
      expect(payment_row("$234.00")).to be_nil
      expect(payment_row("$456.00")).to be_nil
    end

    scenario "can search purchase history by order number" do
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(25)

      fill_in "Search Payments", with: "4567890-1"
      click_button "Search"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(5)
      expect(payment_rows_for_description("LO-01-234-4567890-1").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-1").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-123").count).to eq(1)
    end

    scenario "can search purchase history by payer or payee name" do
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(25)

      fill_in "Search Payments", with: "Buyer 2"
      click_button "Search"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(7)
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
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(25)

      fill_in "q_created_at_date_gteq", with: "Sun, 11 May 2014"
      click_button "Filter"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(16)
      expect(payment_rows_for_description("LO-01-234-4567890-2").count).to eq(2)
      expect(payment_rows_for_description("LO-01-234-4567890-3").count).to eq(2)
      expect(payment_rows_for_description("LO-01-234-4567890-4").count).to eq(2)
      expect(payment_rows_for_description("LO-01-234-4567890-5").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-2").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-3").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-4").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-5").count).to eq(2)

      fill_in "q_created_at_date_lteq", with: "Mon, 12 May 2014"
      click_button "Filter"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(8)
      expect(payment_rows_for_description("LO-01-234-4567890-2").count).to eq(2)
      expect(payment_rows_for_description("LO-01-234-4567890-3").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-2").count).to eq(2)
      expect(payment_rows_for_description("LO-02-234-4567890-3").count).to eq(2)
    end

    scenario "can filter purchase history by payment method" do
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(25)

      select "ACH", from: "Payment Method"
      click_button "Filter"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(7)
      expect(payment_row("$23.00")).not_to be_nil
      expect(payment_row("$23.01")).not_to be_nil
      expect(payment_row("$24.00")).not_to be_nil
      expect(payment_row("$24.01")).not_to be_nil
      expect(payment_row("$99.00")).not_to be_nil
      expect(payment_row("$345.00")).not_to be_nil
    end

    scenario "can filter purchase history by payment type" do
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(25)

      select "Order", from: "Payment Type"
      click_button "Filter"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(23)

      select "Service Fee", from: "Payment Type"
      click_button "Filter"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(1)
    end

    scenario "can filter purchase history by payer" do
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(25)

      select @market.name, from: "Received From"
      click_button "Filter"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(7)

      select "Buyer", from: "Received From"
      click_button "Filter"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(5)
    end

    scenario "can filter purchase history by payee" do
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(25)

      select @market.name, from: "Paid To"
      click_button "Filter"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(5)

      select @seller.name, from: "Paid To"
      click_button "Filter"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(7)

      select @market2.name, from: "Paid To"
      click_button "Filter"

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(6)

      select "Local Orbit", from: "Paid To"
      click_button "Filter"

      # Service Fee + ACH Buyer Payment
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(2)
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
      expect(payment_row("$21.00").date).to eql("05/10/2014")

      expect(payment_row("$22.00")).not_to be_nil
      expect(payment_row("$22.00").payment_method).to eql("Check: #12345")
      expect(payment_row("$22.00").date).to eql("05/11/2014")

      expect(payment_row("$23.00")).not_to be_nil
      expect(payment_row("$23.00").payment_method).to eql("ACH: *********9983")
      expect(payment_row("$23.00").date).to eql("05/12/2014")

      expect(payment_row("$24.00")).not_to be_nil
      expect(payment_row("$24.00").payment_method).to eql("ACH: *********2231")
      expect(payment_row("$24.00").date).to eql("05/13/2014")

      expect(payment_row("$25.00")).not_to be_nil
      expect(payment_row("$25.00").payment_method).to eql("Credit Card: ************7732")
      expect(payment_row("$25.00").date).to eql("05/14/2014")
    end

    scenario "can view their purchase history after market manage deletes an organization" do
      switch_user(market_manager) do
        delete_organization(@seller)
      end

      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(5)

      expect(payment_row("$21.00")).not_to be_nil
      expect(payment_row("$21.00").payment_method).to eql("Cash")
      expect(payment_row("$21.00").date).to eql("05/10/2014")

      expect(payment_row("$22.00")).not_to be_nil
      expect(payment_row("$22.00").payment_method).to eql("Check: #12345")
      expect(payment_row("$22.00").date).to eql("05/11/2014")

      expect(payment_row("$23.00")).not_to be_nil
      expect(payment_row("$23.00").payment_method).to eql("ACH: *********9983")
      expect(payment_row("$23.00").date).to eql("05/12/2014")

      expect(payment_row("$24.00")).not_to be_nil
      expect(payment_row("$24.00").payment_method).to eql("ACH: *********2231")
      expect(payment_row("$24.00").date).to eql("05/13/2014")

      expect(payment_row("$25.00")).not_to be_nil
      expect(payment_row("$25.00").payment_method).to eql("Credit Card: ************7732")
      expect(payment_row("$25.00").date).to eql("05/14/2014")
    end

    scenario "cannot view market-to-seller payments" do
      expect(payment_row("$42.00")).to be_nil
      expect(payment_row("$44.00")).to be_nil
      expect(payment_row("$46.00")).to be_nil
      expect(payment_row("$48.00")).to be_nil
      expect(payment_row("$50.00")).to be_nil
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

      fill_in "q_created_at_date_gteq", with: "Sun, 11 May 2014"
      click_button "Filter"

      expect(page).not_to have_content("LO-01-234-4567890-1")
      expect(page).to     have_content("LO-01-234-4567890-2")
      expect(page).to     have_content("LO-01-234-4567890-3")
      expect(page).to     have_content("LO-01-234-4567890-4")
      expect(page).to     have_content("LO-01-234-4567890-5")

      fill_in "q_created_at_date_lteq", with: "Mon, 12 May 2014"
      click_button "Filter"

      expect(page).not_to have_content("LO-01-234-4567890-1")
      expect(page).to     have_content("LO-01-234-4567890-2")
      expect(page).to     have_content("LO-01-234-4567890-3")
      expect(page).not_to have_content("LO-01-234-4567890-4")
      expect(page).not_to have_content("LO-01-234-4567890-5")
    end
  end

  context "Sellers" do
    let!(:user) { create(:user, organizations: [@seller]) }

    scenario "can view their purchase history" do
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(7)

      expect(payment_row("$42.00")).not_to be_nil
      expect(payment_row("$42.00").payment_method).to eql("Check: #67890")
      expect(payment_row("$42.00").date).to eql("05/10/2014")

      expect(payment_row("$44.00")).not_to be_nil
      expect(payment_row("$44.00").payment_method).to eql("Cash")
      expect(payment_row("$44.00").date).to eql("05/11/2014")

      expect(payment_row("$46.00")).not_to be_nil
      expect(payment_row("$46.00").payment_method).to eql("Check: #67890")
      expect(payment_row("$46.00").date).to eql("05/12/2014")

      expect(payment_row("$48.00")).not_to be_nil
      expect(payment_row("$48.00").payment_method).to eql("Cash")
      expect(payment_row("$48.00").date).to eql("05/13/2014")

      expect(payment_row("$50.00")).not_to be_nil
      expect(payment_row("$50.00").payment_method).to eql("Check: #67890")
      expect(payment_row("$50.00").date).to eql("05/14/2014")

      expect(payment_row("$888.00")).not_to be_nil
      expect(payment_row("$888.00").payment_method).to eql("ACH: *********2231")
      expect(payment_row("$888.00").date).to eql("05/08/2014")

      expect(payment_row("$999.00")).not_to be_nil
      expect(payment_row("$999.00").payment_method).to eql("Check")
      expect(payment_row("$999.00").date).to eql("05/08/2014")
    end

    scenario "can search purchase history by order number" do
      expect(payment_row("$42.00").description).to include("LO-01-234-4567890-1")
      expect(payment_row("$44.00").description).to include("LO-01-234-4567890-2")
      expect(payment_row("$46.00").description).to include("LO-01-234-4567890-3")
      expect(payment_row("$48.00").description).to include("LO-01-234-4567890-4")
      expect(payment_row("$50.00").description).to include("LO-01-234-4567890-5")
      expect(payment_row("$888.00").description).to include("LO-02-234-4567890-888")
      expect(payment_row("$999.00").description).to include("LO-02-234-4567890-999")

      fill_in "Search Payments", with: "4567890-1"
      click_button "Search"

      expect(page).to     have_content("LO-01-234-4567890-1")
      expect(page).not_to have_content("LO-01-234-4567890-2")
      expect(page).not_to have_content("LO-01-234-4567890-3")
      expect(page).not_to have_content("LO-01-234-4567890-4")
      expect(page).not_to have_content("LO-01-234-4567890-5")
    end

    scenario "can filter purchase history by payment date" do
      expect(payment_row("$42.00").description).to include("LO-01-234-4567890-1")
      expect(payment_row("$44.00").description).to include("LO-01-234-4567890-2")
      expect(payment_row("$46.00").description).to include("LO-01-234-4567890-3")
      expect(payment_row("$48.00").description).to include("LO-01-234-4567890-4")
      expect(payment_row("$50.00").description).to include("LO-01-234-4567890-5")
      expect(payment_row("$888.00").description).to include("LO-02-234-4567890-888")
      expect(payment_row("$999.00").description).to include("LO-02-234-4567890-999")

      fill_in "q_created_at_date_gteq", with: "Sun, 11 May 2014"
      click_button "Filter"

      expect(page).not_to have_content("LO-01-234-4567890-1")
      expect(page).to     have_content("LO-01-234-4567890-2")
      expect(page).to     have_content("LO-01-234-4567890-3")
      expect(page).to     have_content("LO-01-234-4567890-4")
      expect(page).to     have_content("LO-01-234-4567890-5")

      fill_in "q_created_at_date_lteq", with: "Mon, 12 May 2014"
      click_button "Filter"

      expect(page).not_to have_content("LO-01-234-4567890-1")
      expect(page).to     have_content("LO-01-234-4567890-2")
      expect(page).to     have_content("LO-01-234-4567890-3")
      expect(page).not_to have_content("LO-01-234-4567890-4")
      expect(page).not_to have_content("LO-01-234-4567890-5")
    end

    scenario "can filter purchase history by payment method" do
      expect(payment_row("$42.00").description).to include("LO-01-234-4567890-1")
      expect(payment_row("$44.00").description).to include("LO-01-234-4567890-2")
      expect(payment_row("$46.00").description).to include("LO-01-234-4567890-3")
      expect(payment_row("$48.00").description).to include("LO-01-234-4567890-4")
      expect(payment_row("$50.00").description).to include("LO-01-234-4567890-5")
      expect(payment_row("$888.00").description).to include("LO-02-234-4567890-888")
      expect(payment_row("$999.00").description).to include("LO-02-234-4567890-999")

      select "Check", from: "Payment Method"
      click_button "Filter"

      expect(page).to     have_content("LO-01-234-4567890-1")
      expect(page).not_to have_content("LO-01-234-4567890-2")
      expect(page).to     have_content("LO-01-234-4567890-3")
      expect(page).not_to have_content("LO-01-234-4567890-4")
      expect(page).to     have_content("LO-01-234-4567890-5")

      select "Cash", from: "Payment Method"
      click_button "Filter"

      expect(page).not_to have_content("LO-01-234-4567890-1")
      expect(page).to     have_content("LO-01-234-4567890-2")
      expect(page).not_to have_content("LO-01-234-4567890-3")
      expect(page).to     have_content("LO-01-234-4567890-4")
      expect(page).not_to have_content("LO-01-234-4567890-5")
    end
  end
end
