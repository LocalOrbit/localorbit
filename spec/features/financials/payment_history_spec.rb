require "spec_helper"

feature "Payment history" do
  let(:market_ach_balanced_uri) { "http://balanced.example.com/12345" }
  let(:ach_balanced_uri) { "http://balanced.example.com/123456" }
  let(:other_ach_balanced_uri) { "http://balanced.example.com/12345687" }
  let(:cc_balanced_uri) { "http://balanced.example.com/1234567" }

  let!(:market)             { create(:market, po_payment_term: 30, timezone: "Eastern Time (US & Canada)") }
  let!(:market2)            { create(:market, po_payment_term: 30, timezone: "Eastern Time (US & Canada)") }
  let!(:market3)            { create(:market, po_payment_term: 30, timezone: "Eastern Time (US & Canada)") }
  let!(:market_ach_account) { create(:bank_account, :checking, last_four: "7676", balanced_uri: market_ach_balanced_uri, bankable: market) }
  let!(:service_fee)        { create(:payment, payment_method: 'ach', payment_type: 'service', payee: market, amount: 99.00) }

  let!(:buyer)   { create(:organization, markets: [market], can_sell: false) }
  let!(:buyer2)  { create(:organization, markets: [market2, market3], can_sell: false) }
  let!(:seller)  { create(:organization, markets: [market], can_sell: true) }
  let!(:seller2) { create(:organization, markets: [market2], can_sell: true) }

  let(:payment_day) { DateTime.parse("May 9, 2014, 11:00:00") }

  let!(:ach_account) { create(:bank_account, :checking, last_four: "9983", balanced_uri: ach_balanced_uri, bankable: buyer) }
  let!(:other_ach_account) { create(:bank_account, :checking, last_four: "2231", balanced_uri: other_ach_balanced_uri, bankable: buyer) }
  let!(:cc_account) { create(:bank_account, :credit_card, last_four: "7732", balanced_uri: cc_balanced_uri, bankable: buyer) }

  before do
    order_item = create(:order_item, unit_price: 6.50, quantity: 2)
    create(:order, items: [order_item], organization: buyer, payment_method: "purchase order", total_cost: 13.00)

    order_item = create(:order_item, unit_price: 36.00, quantity: 2)
    create(:order, items: [order_item], organization: buyer, payment_method: "ach", total_cost: 72.00)

    order_item = create(:order_item, unit_price: 129.00, quantity: 1)
    create(:order, items: [order_item], organization: buyer, payment_method: "credit card", total_cost: 129.00)

    orders = []
    orders2 = []
    6.times do |i|
      order_item = create(:order_item, unit_price: 20.00 + i, quantity: 1)
      orders << create(:order,
                       items: [order_item],
                       organization: buyer,
                       payment_method: ["purchase order", "purchase order", "purchase order", "ach", "ach", "credit card"][i],
                       payment_status: "paid",
                       order_number: "LO-01-234-4567890-#{i}")
      orders2 << create(:order,
                       items: [order_item],
                       organization: buyer2,
                       payment_method: ["purchase order", "purchase order", "purchase order", "ach", "ach", "credit card"][i],
                       payment_status: "paid",
                       order_number: "LO-02-234-4567890-#{i}")
    end

    (1..5).each do |i|
      Timecop.freeze(payment_day + i.days) do
        # Create payment from buyer to market
        payment = create(:payment,
                         payment_method: ["cash", "check", "ach", "ach", "credit card"][i - 1],
                         payee: market,
                         orders: [orders[i]],
                         amount: orders[i].total_cost)

        payment.update_attribute(:note, "#12345") if i == 1
        payment.update_attribute(:balanced_uri, ach_balanced_uri) if i == 2
        payment.update_attributes(balanced_uri: other_ach_balanced_uri, status: "pending") if i == 3
        payment.update_attribute(:balanced_uri, cc_balanced_uri) if i == 4

        payment2 = create(:payment,
                         payment_method: ["cash", "check", "ach", "ach", "credit card"][i - 1],
                         payee: market2,
                         orders: [orders2[i]],
                         amount: orders2[i].total_cost)

        payment2.update_attribute(:note, "#12345") if i == 1
        payment2.update_attribute(:balanced_uri, ach_balanced_uri) if i == 2
        payment2.update_attributes(balanced_uri: other_ach_balanced_uri, status: "pending") if i == 3
        payment2.update_attribute(:balanced_uri, cc_balanced_uri) if i == 4

        # Create payment from market to seller
        create(:payment,
               payment_method: ["cash", "check"][i % 2],
               payee: seller,
               orders: [orders[i]],
               amount: orders[i].total_cost * 2)

        # Create payment from market to seller2
        create(:payment,
               payment_method: ["cash", "check"][i % 2],
               payee: seller2,
               orders: [orders2[i]],
               amount: orders2[i].total_cost * 2)
      end
    end

    # Multiple market payments
    Timecop.freeze(payment_day - 1.day) do
      # Create a cash buyer payment for a market that IS managed by our market manager
      order = create(:order,
                    items: [create(:order_item, unit_price: 123.00, quantity: 1)],
                    organization: buyer2,
                    market: market2,
                    payment_method: "purchase order",
                    payment_status: "paid",
                    order_number: "LO-02-234-4567890-123")
      create(:payment,
            payment_method: "cash",
            payer: buyer2,
            payee: market2,
            orders: [order],
            amount: order.total_cost)

      # Create a cash buyer payment for a market that IS NOT managed by our market manager
      order = create(:order,
                    items: [create(:order_item, unit_price: 234.00, quantity: 1)],
                    organization: buyer2,
                    market: market3,
                    payment_method: "purchase order",
                    payment_status: "paid",
                    order_number: "LO-02-234-4567890-234")
      create(:payment,
            payment_method: "cash",
            payer: buyer2,
            payee: market3,
            orders: [order],
            amount: order.total_cost)

      # Create an ACH buyer payment for a market that IS managed by our market manager
      order = create(:order,
                    items: [create(:order_item, unit_price: 345.00, quantity: 1)],
                    organization: buyer2,
                    market: market2,
                    payment_method: "ach",
                    payment_status: "paid",
                    order_number: "LO-02-234-4567890-345")
      create(:payment,
            payment_method: "ach",
            payer: buyer2,
            payee: nil,
            orders: [order],
            amount: order.total_cost,
            balanced_uri: ach_balanced_uri)

      # Create an ACH buyer payment for a market that IS NOT managed by our market manager
      order = create(:order,
                    items: [create(:order_item, unit_price: 456.00, quantity: 1)],
                    organization: buyer2,
                    market: market3,
                    payment_method: "ach",
                    payment_status: "paid",
                    order_number: "LO-02-234-4567890-456")
      create(:payment,
            payment_method: "ach",
            payer: buyer2,
            payee: nil,
            orders: [order],
            amount: order.total_cost,
            balanced_uri: other_ach_balanced_uri)
    end

    switch_to_subdomain(market.subdomain)
    sign_in_as(user)

    click_link "Financials"
    click_link "Review Payment History"

    expect(page).to have_content("Payment History")
    expect(page).to have_content("Payment Date")
    expect(page).to have_content("Description")
    expect(page).to have_content("Payment Method")
    expect(page).to have_content("Amount")
  end

  def payment_row(amount)
    Dom::Admin::Financials::PaymentRow.find_by_amount(amount)
  end

  context "Market Managers" do
    let!(:user)    { create(:user, :market_manager, managed_markets: [market, market2]) }

    scenario "can view buyer order payments for markets they manage" do
      expect(payment_row("$123.00")).not_to be_nil
      expect(payment_row("$123.00").payment_method).to eql("Cash")
      expect(payment_row("$123.00").date).to eql("05/08/2014")

      expect(payment_row("$345.00")).not_to be_nil
      expect(payment_row("$345.00").payment_method).to eql("ACH: *********9983")
      expect(payment_row("$345.00").date).to eql("05/08/2014")
    end

    scenario "cannot view buyer order payments for markets they do not manage" do
      expect(payment_row("$234.00")).to be_nil
      expect(payment_row("$456.00")).to be_nil
    end

    scenario "can view their purchase history" do
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(5)

      expect(payment_row("$21.00")).not_to be_nil
      expect(payment_row("$21.00").payment_method).to eql("Cash")
      expect(payment_row("$21.00").date).to eql("05/09/2014")

      expect(payment_row("$22.00")).not_to be_nil
      expect(payment_row("$22.00").payment_method).to eql("Check: #12345")
      expect(payment_row("$22.00").date).to eql("05/10/2014")

      expect(payment_row("$23.00")).not_to be_nil
      expect(payment_row("$23.00").payment_method).to eql("ACH: *********9983")
      expect(payment_row("$23.00").date).to eql("05/11/2014")

      expect(payment_row("$24.00")).not_to be_nil
      expect(payment_row("$24.00").payment_method).to eql("ACH: *********2231")
      expect(payment_row("$24.00").date).to eql("05/12/2014")

      expect(payment_row("$25.00")).not_to be_nil
      expect(payment_row("$25.00").payment_method).to eql("Credit Card: ************7732")
      expect(payment_row("$25.00").date).to eql("05/13/2014")

      expect(payment_row("$99.00")).to be_nil
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

      fill_in "q_updated_at_date_gteq", with: "Sat, 10 May 2014"
      click_button "Update"

      expect(page).not_to have_content("LO-01-234-4567890-1")
      expect(page).to     have_content("LO-01-234-4567890-2")
      expect(page).to     have_content("LO-01-234-4567890-3")
      expect(page).to     have_content("LO-01-234-4567890-4")
      expect(page).to     have_content("LO-01-234-4567890-5")

      fill_in "q_updated_at_date_lteq", with: "Sun, 11 May 2014"
      click_button "Update"

      expect(page).not_to have_content("LO-01-234-4567890-1")
      expect(page).to     have_content("LO-01-234-4567890-2")
      expect(page).to     have_content("LO-01-234-4567890-3")
      expect(page).not_to have_content("LO-01-234-4567890-4")
      expect(page).not_to have_content("LO-01-234-4567890-5")
    end
  end

  context "Buyers" do
    let!(:user) { create(:user, organizations: [buyer]) }

    scenario "can view their purchase history" do
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(10)

      expect(payment_row("$21.00")).not_to be_nil
      expect(payment_row("$21.00").payment_method).to eql("Cash")
      expect(payment_row("$21.00").date).to eql("05/09/2014")

      expect(payment_row("$22.00")).not_to be_nil
      expect(payment_row("$22.00").payment_method).to eql("Check: #12345")
      expect(payment_row("$22.00").date).to eql("05/10/2014")

      expect(payment_row("$23.00")).not_to be_nil
      expect(payment_row("$23.00").payment_method).to eql("ACH: *********9983")
      expect(payment_row("$23.00").date).to eql("05/11/2014")

      expect(payment_row("$24.00")).not_to be_nil
      expect(payment_row("$24.00").payment_method).to eql("ACH: *********2231")
      expect(payment_row("$24.00").date).to eql("05/12/2014")

      expect(payment_row("$25.00")).not_to be_nil
      expect(payment_row("$25.00").payment_method).to eql("Credit Card: ************7732")
      expect(payment_row("$25.00").date).to eql("05/13/2014")

      expect(payment_row("$99.00")).to be_nil
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

      fill_in "q_updated_at_date_gteq", with: "Sat, 10 May 2014"
      click_button "Filter"

      expect(page).not_to have_content("LO-01-234-4567890-1")
      expect(page).to     have_content("LO-01-234-4567890-2")
      expect(page).to     have_content("LO-01-234-4567890-3")
      expect(page).to     have_content("LO-01-234-4567890-4")
      expect(page).to     have_content("LO-01-234-4567890-5")

      fill_in "q_updated_at_date_lteq", with: "Sun, 11 May 2014"
      click_button "Filter"

      expect(page).not_to have_content("LO-01-234-4567890-1")
      expect(page).to     have_content("LO-01-234-4567890-2")
      expect(page).to     have_content("LO-01-234-4567890-3")
      expect(page).not_to have_content("LO-01-234-4567890-4")
      expect(page).not_to have_content("LO-01-234-4567890-5")
    end
  end

  context "Sellers" do
    let!(:user) { create(:user, organizations: [seller]) }

    scenario "can view their purchase history" do
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(5)

      expect(payment_row("$42.00")).not_to be_nil
      expect(payment_row("$42.00").payment_method).to eql("Check")
      expect(payment_row("$42.00").date).to eql("05/10/2014")

      expect(payment_row("$44.00")).not_to be_nil
      expect(payment_row("$44.00").payment_method).to eql("Cash")
      expect(payment_row("$44.00").date).to eql("05/11/2014")

      expect(payment_row("$46.00")).not_to be_nil
      expect(payment_row("$46.00").payment_method).to eql("Check")
      expect(payment_row("$46.00").date).to eql("05/12/2014")

      expect(payment_row("$48.00")).not_to be_nil
      expect(payment_row("$48.00").payment_method).to eql("Cash")
      expect(payment_row("$48.00").date).to eql("05/13/2014")

      expect(payment_row("$50.00")).not_to be_nil
      expect(payment_row("$50.00").payment_method).to eql("Check")
      expect(payment_row("$50.00").date).to eql("05/14/2014")
    end

    scenario "can search purchase history by order number" do
      expect(payment_row("$42.00").description).to include("LO-01-234-4567890-1")
      expect(payment_row("$44.00").description).to include("LO-01-234-4567890-2")
      expect(payment_row("$46.00").description).to include("LO-01-234-4567890-3")
      expect(payment_row("$48.00").description).to include("LO-01-234-4567890-4")
      expect(payment_row("$50.00").description).to include("LO-01-234-4567890-5")

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

      fill_in "q_updated_at_date_gteq", with: "Sat, 10 May 2014"
      click_button "Filter"

      expect(page).not_to have_content("LO-01-234-4567890-1")
      expect(page).to     have_content("LO-01-234-4567890-2")
      expect(page).to     have_content("LO-01-234-4567890-3")
      expect(page).to     have_content("LO-01-234-4567890-4")
      expect(page).to     have_content("LO-01-234-4567890-5")

      fill_in "q_updated_at_date_lteq", with: "Sun, 11 May 2014"
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

      select "Cash", from: "q_payment_method_eq"
      click_button "Filter"

      expect(page).to     have_content("LO-01-234-4567890-1")
      expect(page).not_to have_content("LO-01-234-4567890-2")
      expect(page).to     have_content("LO-01-234-4567890-3")
      expect(page).not_to have_content("LO-01-234-4567890-4")
      expect(page).to     have_content("LO-01-234-4567890-5")

      select "Check", from: "q_payment_method_eq"
      click_button "Filter"

      expect(page).not_to have_content("LO-01-234-4567890-1")
      expect(page).to     have_content("LO-01-234-4567890-2")
      expect(page).not_to have_content("LO-01-234-4567890-3")
      expect(page).to     have_content("LO-01-234-4567890-4")
      expect(page).not_to have_content("LO-01-234-4567890-5")
    end
  end
end
