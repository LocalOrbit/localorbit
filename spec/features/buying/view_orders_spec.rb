require "spec_helper"

feature "Viewing orders" do
  let(:market)       { create(:market) }

  let(:organization) { create(:organization, markets: [market]) }
  let!(:user)        { create(:user, :market_manager, managed_markets: [market]) }

  let!(:order) {create(:order, :with_items, payment_method: "credit card", organization: organization, market: market, delivery_fees: 10)}

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
      expect(page).to have_content("Delivery Fee: $0.00")
  end
end