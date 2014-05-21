require "spec_helper"

describe "Payment history" do
  let!(:market) { create(:market, :with_addresses) }
  let!(:seller) { create(:organization, :seller, markets: [market]) }
  let!(:user)   { create(:user, organizations: [seller]) }

  context "with payments" do
    let!(:order2)   { create(:order, :with_items) }
    let!(:payment2) { create(:payment, payee: seller, payment_method: "Cash", amount: 42.00, updated_at: DateTime.parse("May 1, 2014 12:00"), orders: [order2])}
    let!(:order1)   { create(:order, :with_items) }
    let!(:payment1) { create(:payment, payee: seller, amount: 100.00, updated_at: DateTime.parse("May 5, 2014 12:00"), orders: [order1])}

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      visit admin_financials_payments_path
    end

    it "displays the latest payment history" do
      pending
      expect(page).to have_content("Payment History")

      payments = Dom::Admin::Financials::PaymentRow.all
      expect(payments.count).to eql(2)

      expect(payments[0].date).to have_content("05/05/2014")
      expect(payments[0].order_number).to have_content(order1.order_number)
      expect(payments[0].payment_method).to have_content("Purchase Order")
      expect(payments[0].amount).to have_content("$100.00")

      expect(payments[1].date).to have_content("05/01/2014")
      expect(payments[1].order_number).to have_content(order2.order_number)
      expect(payments[1].payment_method).to have_content("Cash")
      expect(payments[1].amount).to have_content("$42.00")
    end
  end

  context "without payments" do
    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      visit admin_financials_payments_path
    end

    it "displays the payment history with a placeholder" do
      expect(page).to have_content("Payment History")
      expect(page).to have_content("No Results")
    end
  end
end
