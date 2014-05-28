require "spec_helper"

feature "Payment history" do
  let(:market_ach_balanced_uri) { "http://balanced.example.com/12345" }
  let(:ach_balanced_uri) { "http://balanced.example.com/123456" }
  let(:other_ach_balanced_uri) { "http://balanced.example.com/12345687" }
  let(:cc_balanced_uri) { "http://balanced.example.com/1234567" }

  let!(:market)             { create(:market, po_payment_term: 30, timezone: "Eastern Time (US & Canada)") }
  let!(:market_ach_account) { create(:bank_account, :checking, last_four: "7676", balanced_uri: market_ach_balanced_uri, bankable: market) }
  let!(:service_fee)        { create(:payment, payment_method: 'ach', payment_type: 'service', payee: market, amount: 99.00) }

  let!(:buyer)  { create(:organization, markets: [market], can_sell: false) }
  let!(:seller)  { create(:organization, markets: [market], can_sell: true) }
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
    6.times do |i|
      order_item = create(:order_item, unit_price: 20.00 + i, quantity: 1)
      orders << create(:order,
                       items: [order_item],
                       organization: buyer,
                       payment_method: ["purchase order", "purchase order", "purchase order", "ach", "ach", "credit card"][i],
                       payment_status: "paid",
                       order_number: "LO-01-234-4567890-#{i}")
    end

    orders[1..5].each_with_index do |order, i|
      Timecop.freeze(payment_day + i.days) do
        # Create payment from buyer to market
        payment = create(:payment,
                         payment_method: ["cash", "check", "ach", "ach", "credit card"][i],
                         payee: market,
                         orders: [order],
                         amount: order.total_cost)

        payment.update_attribute(:note, "#12345") if i == 1
        payment.update_attribute(:balanced_uri, ach_balanced_uri) if i == 2
        payment.update_attributes(balanced_uri: other_ach_balanced_uri, status: "pending") if i == 3
        payment.update_attribute(:balanced_uri, cc_balanced_uri) if i == 4

        # Create payment from market to seller
        create(:payment,
               payment_method: ["cash", "check"][i % 2],
               payee: seller,
               orders: [order],
               amount: order.total_cost * 2)
      end
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

  context "Buyers" do
    let!(:user) { create(:user, organizations: [buyer]) }

    scenario "can view their purchase history" do
      expect(payment_row("$13.00")).to be_nil
      expect(payment_row("$72.00")).to be_nil
      expect(payment_row("$129.00")).to be_nil

      # Don't show PO payments that have not been paid
      expect(payment_row("$20.00")).to be_nil

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

  context "Sellers" do
    let!(:user) { create(:user, organizations: [seller]) }

    scenario "can view their purchase history" do
      expect(Dom::Admin::Financials::PaymentRow.all.count).to eq(5)

      expect(payment_row("$42.00")).not_to be_nil
      expect(payment_row("$42.00").payment_method).to eql("Cash")
      expect(payment_row("$42.00").date).to eql("05/09/2014")

      expect(payment_row("$44.00")).not_to be_nil
      expect(payment_row("$44.00").payment_method).to eql("Check")
      expect(payment_row("$44.00").date).to eql("05/10/2014")

      expect(payment_row("$46.00")).not_to be_nil
      expect(payment_row("$46.00").payment_method).to eql("Cash")
      expect(payment_row("$46.00").date).to eql("05/11/2014")

      expect(payment_row("$48.00")).not_to be_nil
      expect(payment_row("$48.00").payment_method).to eql("Check")
      expect(payment_row("$48.00").date).to eql("05/12/2014")

      expect(payment_row("$50.00")).not_to be_nil
      expect(payment_row("$50.00").payment_method).to eql("Cash")
      expect(payment_row("$50.00").date).to eql("05/13/2014")
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

    scenario "can filter purchase history by payment method" do
      expect(payment_row("$42.00").description).to include("LO-01-234-4567890-1")
      expect(payment_row("$44.00").description).to include("LO-01-234-4567890-2")
      expect(payment_row("$46.00").description).to include("LO-01-234-4567890-3")
      expect(payment_row("$48.00").description).to include("LO-01-234-4567890-4")
      expect(payment_row("$50.00").description).to include("LO-01-234-4567890-5")

      select "Cash", from: "q_payment_method_eq"
      click_button "Update"

      expect(page).to     have_content("LO-01-234-4567890-1")
      expect(page).not_to have_content("LO-01-234-4567890-2")
      expect(page).to     have_content("LO-01-234-4567890-3")
      expect(page).not_to have_content("LO-01-234-4567890-4")
      expect(page).to     have_content("LO-01-234-4567890-5")

      select "Check", from: "q_payment_method_eq"
      click_button "Update"

      expect(page).not_to have_content("LO-01-234-4567890-1")
      expect(page).to     have_content("LO-01-234-4567890-2")
      expect(page).not_to have_content("LO-01-234-4567890-3")
      expect(page).to     have_content("LO-01-234-4567890-4")
      expect(page).not_to have_content("LO-01-234-4567890-5")
    end
  end
end
