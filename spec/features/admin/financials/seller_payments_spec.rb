require "spec_helper"

feature "Paying sellsers on the automate plan" do
  let(:today) { 1.week.ago }
  let!(:plan) { create(:plan, :automate) }

  let!(:market1) { create(:market, name: "Baskerville Co-op", po_payment_term: 14, plan: plan) }
  let!(:market1_delivery_schedule) { create(:delivery_schedule, market: market1, day: (today - 3.day).wday) }
  let!(:market1_delivery) { Timecop.freeze(today - 5.days) { market1_delivery_schedule.next_delivery } }
  let!(:market_manager) { create :user, managed_markets: [market1] }

  let!(:market1_seller1) { create(:organization, :seller, name: "Better Farms", markets: [market1]) }
  let!(:market1_seller2) { create(:organization, :seller, name: "Great Farms", markets: [market1]) }
  let!(:market1_seller3) { create(:organization, :seller, name: "Betterest Farms", markets: [market1]) }
  let!(:market1_seller4) { create(:organization, :seller, name: "Greater Farms", markets: [market1]) }
  let!(:market1_buyer)  { create(:organization, :buyer, name: "Money Bags", markets: [market1]) }

  let!(:market1_product1) { create(:product, :sellable, organization: market1_seller1) }
  let!(:market1_product2) { create(:product, :sellable, organization: market1_seller2) }
  let!(:market1_product3) { create(:product, :sellable, organization: market1_seller2) }
  let!(:market1_product4) { create(:product, :sellable, organization: market1_seller3) }

  let!(:market1_order1) do
    create(:order,
           market: market1,
           organization: market1_buyer,
           delivery: market1_delivery,
           payment_method: "ach",
           order_number: "LO-001",
           total_cost: 27.96,
           placed_at: today - 19.days)
  end

  let!(:market1_order1_item1) do
    create(:order_item,
           :delivered,
           product: market1_product1,
           quantity: 4,
           order: market1_order1)
  end

  let!(:market1_order2) { create(:order, items: [create(:order_item, :delivered, product: market1_product2, quantity: 3), create(:order_item, :delivered, product: market1_product4, quantity: 7)], market: market1, organization: market1_buyer, delivery: market1_delivery, payment_method: "ach", order_number: "LO-002", total_cost: 69.90, placed_at: today - 6.days, payment_status: "paid") }
  let!(:market1_order3) { create(:order, items: [create(:order_item, :delivered, product: market1_product3, quantity: 6)], market: market1, organization: market1_buyer, delivery: market1_delivery, payment_method: "ach", order_number: "LO-003", total_cost: 41.94, placed_at: today - 4.days) }
  let!(:market1_order4) { create(:order, items: [create(:order_item, :delivered, product: market1_product2, quantity: 9), create(:order_item, :delivered, product: market1_product3, quantity: 14)], market: market1, organization: market1_buyer, delivery: market1_delivery, payment_method: "ach", order_number: "LO-004", total_cost: 160.77, placed_at: today - 3.days) }
  let!(:market1_order5) { create(:order, items: [create(:order_item, :delivered, product: market1_product2, quantity: 9), create(:order_item, :delivered, product: market1_product3, quantity: 14)], market: market1, organization: market1_buyer, delivery: market1_delivery, payment_method: "ach", order_number: "LO-005", total_cost: 160.77, placed_at: today - 80.days) }

  let(:balanced_uri) { "/v1/marketplaces/TEST-MP4X7mSSQwAyDzwUfc5TAQ7D/bank_accounts/BA1YqNWvILpfyq9FqSDPLhCO" }
  let!(:bank_account) { create(:bank_account, :checking, :verified, last_four: "9983", balanced_uri: balanced_uri, bankable: market1_seller2) }

  let(:balanced_uri) { "/v1/marketplaces/TEST-MP4X7mSSQwAyDzwUfc5TAQ7D/bank_accounts/BA1YqNWvILpfyq9FqSDPLhCO" }
  let!(:bank_account) { create(:bank_account, :checking, last_four: "9983", balanced_uri: balanced_uri, bankable: market1_seller2) }


  let!(:user) { create(:user, :admin) }


  before do
    deliver_order(market1_order1)
  end


  scenario "admin can pay Sellers" do
    switch_to_subdomain("app")
    sign_in_as user
    visit admin_financials_seller_payments_path
    expect(page).to have_content("Make Payments to Sellers")
    expect(page).to have_content("Betterest Farm")
    expect(page).to have_content("Great Farms")
    expect(page).to have_content("NOT VERIFIED")
    save_and_open_page
    click_button "Pay Great Farms"
    expect(page).to have_content("Payment recorded")


  end
end