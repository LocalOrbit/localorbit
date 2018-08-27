require "spec_helper"

feature "Viewing orders" do
  let(:market)       { create(:market) }

  let(:organization) { create(:organization, markets: [market]) }
  let!(:user)        { create(:user, :market_manager, managed_markets: [market]) }

  let!(:order) {create(:order, :with_items, payment_method: "credit card", organization: organization, market: market, delivery_fees: 10) }
  let!(:order2) {create(:order, :with_items, payment_method: "purchase order", organization: organization, market: market, delivery_fees: 10, placed_at: 1.week.ago, invoiced_at: 2.day.ago, invoice_due_date: 30.days.from_now) }

  before do
    switch_to_subdomain market.subdomain
  end

  scenario "view order", :js do
      sign_in_as(user)
      visit admin_orders_path

      click_link order.order_number
      expect(page).to have_content("Delivery Fee: $10.00")

      expect(page).to have_content("Order info")
      find('.icon-clear',:visible => true).click
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_content("Delivery Fee: $0.00")
  end

  scenario "uninvoice order", :js do
    sign_in_as(user)
    visit admin_orders_path

    click_link order2.order_number
    expect(page).to have_content("Invoiced")

    expect(page).to have_content("Uninvoice Order")
    click_button "Uninvoice Order"
    expect(page).to_not have_content("/ Invoiced")
  end

  #scenario "add item", :js do
  #  sign_in_as(user)
  #  visit admin_orders_path
  #  click_link order.order_number

  #  expect(page).to have_button("Add Items")
  #  click_button "Add Items"
  #  expect(page).to have_content("celery")

  #end
end
