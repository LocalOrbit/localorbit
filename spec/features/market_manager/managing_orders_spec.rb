require "spec_helper"

feature "Managing orders", :js do
  let(:market)       { create(:market) }

  let(:organization) { create(:organization, markets: [market]) }
  let!(:user)        { create(:user, :market_manager, managed_markets: [market]) }

  let!(:order) {create(:order, :with_items, payment_method: "credit card", organization: organization, market: market, delivery_fees: 10) }
  let!(:order2) {create(:order, :with_items, payment_method: "purchase order", organization: organization, market: market, delivery_fees: 10, placed_at: 1.week.ago, invoiced_at: 2.day.ago, invoice_due_date: 30.days.from_now) }

  before do
    switch_to_subdomain market.subdomain
    sign_in_as(user)
    visit admin_orders_path
  end

  context "when viewing an individual order" do
    context "paid with credit card" do
      before do
        click_link order.order_number
      end

      it "manager can remove delivery fee" do
        expect(page).to have_content("Delivery Fee: $10.00")
        find('.icon-clear').click
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content("Delivery Fee: $0.00")
      end
    end

    context "paid with purchase order" do
      before do
        click_link order2.order_number
      end

      it "manager can uninvoice an order" do
        expect(page).to have_content("Invoiced")
        click_button "Uninvoice Order"
        expect(page).to_not have_content("/ Invoiced")
      end
    end
  end
end
