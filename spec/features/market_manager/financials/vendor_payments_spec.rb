require "spec_helper"

feature "Payments to vendors" do
  let(:market1) { create(:market, name: "Baskerville Co-op", po_payment_term: 14) }
  let!(:market1_delivery_schedule) { create(:delivery_schedule, market: market1, day: 3.days.ago.wday) }
  let!(:market1_delivery) { Timecop.freeze(5.days.ago) { market1_delivery_schedule.next_delivery } }
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

  let!(:market1_order1) { create(:order, items:[create(:order_item, :delivered, product: market1_product1, quantity: 4)], market: market1, organization: market1_buyer, delivery: market1_delivery, payment_method: "purchase order", order_number: "LO-001", total_cost: 27.96, placed_at: 19.days.ago) }
  let!(:market1_order2) { create(:order, items:[create(:order_item, :delivered, product: market1_product2, quantity: 3), create(:order_item, :delivered, product: market1_product4, quantity: 7)], market: market1, organization: market1_buyer, delivery: market1_delivery, payment_method: "purchase order", order_number: "LO-002", total_cost: 69.90, placed_at: 6.days.ago, payment_status: "paid") }
  let!(:market1_order3) { create(:order, items:[create(:order_item, :delivered, product: market1_product3, quantity: 6)], market: market1, organization: market1_buyer, delivery: market1_delivery, payment_method: "purchase order", order_number: "LO-003", total_cost: 41.94, placed_at: 4.days.ago) }
  let!(:market1_order4) { create(:order, items:[create(:order_item, :delivered, product: market1_product2, quantity: 9), create(:order_item, :delivered, product: market1_product3, quantity: 14)], market: market1, organization: market1_buyer, delivery: market1_delivery, payment_method: "purchase order", order_number: "LO-004", total_cost: 160.77, placed_at: 3.days.ago) }

  scenario "displays the correct items" do
    switch_to_subdomain(market1.subdomain)
    sign_in_as market_manager
    visit admin_financials_vendor_payments_path
    seller_rows = Dom::Admin::Financials::VendorPaymentRow.all

    expect(seller_rows.size).to eq(3)
    expect(seller_rows[0].name).to have_content("Better Farms")
    expect(seller_rows[0].order_count).to have_content(/\A1 order from Baskerville Co-op Review/)
    expect(seller_rows[0].owed).to have_content("$27.96")

    expect(seller_rows[1].name).to have_content("Betterest Farms")
    expect(seller_rows[1].order_count).to have_content(/\A1 order from Baskerville Co-op Review/)
    expect(seller_rows[1].owed).to have_content("$48.93")

    expect(seller_rows[2].name).to have_content("Great Farms")
    expect(seller_rows[2].order_count).to have_content(/\A3 orders from Baskerville Co-op Review/)
    expect(seller_rows[2].owed).to have_content("$223.68")
  end

  scenario "de-selecting orders", :js do
    switch_to_subdomain(market1.subdomain)
    sign_in_as market_manager
    visit admin_financials_vendor_payments_path

    seller_row = Dom::Admin::Financials::VendorPaymentRow.for_seller("Great Farms")
    seller_row.review

    orders = Dom::Admin::Financials::VendorPaymentOrderRow.all

    expect(orders.size).to eq(3)
    expect(orders[0].order_number).to eq('LO-002')
    expect(orders[0].placed_at).to have_content(market1_order2.placed_at.strftime("%b %d, %Y"))
    expect(orders[0].total).to have_content('$20.97')

    expect(orders[1].order_number).to eq('LO-003')
    expect(orders[1].placed_at).to have_content(market1_order3.placed_at.strftime("%b %d, %Y"))
    expect(orders[1].total).to have_content('$41.94')

    expect(orders[2].order_number).to eq('LO-004')
    expect(orders[2].placed_at).to have_content(market1_order4.placed_at.strftime("%b %d, %Y"))
    expect(orders[2].total).to have_content('$160.77')

    expect(seller_row.selected_owed).to have_content("$223.68")

    orders[1].click_check

    expect(seller_row.selected_owed).to have_content("$181.74")
  end

  scenario "mark all orders for seller paid", :js do
    switch_to_subdomain(market1.subdomain)
    sign_in_as market_manager
    visit admin_financials_vendor_payments_path
    seller_row = Dom::Admin::Financials::VendorPaymentRow.for_seller("Great Farms")
    seller_row.pay_all_now

    choose "Check"
    fill_in "Check #", with: "4234"

    within('.record-payment') do
      find_button("Record Payment").trigger('click')
    end

    expect(page).to have_content("Payment of $223.68 recorded for Great Farms")

    # Great Farms should no longer be in the payments list
    seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
    expect(seller_rows.map {|r| r.name.text }).to eq(["Better Farms", "Betterest Farms"])
  end

  scenario "mark selected orders for seller paid", :js do
    switch_to_subdomain(market1.subdomain)
    sign_in_as market_manager
    visit admin_financials_vendor_payments_path
    seller_row = Dom::Admin::Financials::VendorPaymentRow.for_seller("Great Farms")
    seller_row.review

    orders = Dom::Admin::Financials::VendorPaymentOrderRow.all
    orders[1].click_check

    seller_row.pay_selected

    choose "Check"
    fill_in "Check #", with: "4234"

    within('.record-payment') do
      click_button "Record Payment"
    end

    expect(page).to have_content("Payment of $181.74 recorded for Great Farms")

    # Great Farms should still be in the payments list
    seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
    expect(seller_rows.map {|r| r.name.text }).to eq(["Better Farms", "Betterest Farms", "Great Farms"])

    # With 1 order
    expect(seller_rows[2].name).to have_content("Great Farms")
    expect(seller_rows[2].order_count).to have_content(/\A1 order from Baskerville Co-op Review/)
    expect(seller_rows[2].owed).to have_content("$41.94")
  end


  context "filtering" do
    let(:market2) { create(:market, name: "Jonesville Co-op", po_payment_term: 14) }
    let!(:market1_delivery_schedule) { create(:delivery_schedule, market: market2, day: 3.days.ago.wday) }
    let!(:market2_delivery) { Timecop.freeze(5.days.ago) { market1_delivery_schedule.next_delivery } }
    let!(:market_manager) { create :user, managed_markets: [market1, market2] }

    let!(:market2_seller1) { create(:organization, :seller, name: "Best Farms", markets: [market2]) }
    let!(:market2_seller2) { create(:organization, :seller, name: "Fruit Farms", markets: [market2]) }
    let!(:market2_seller3) { create(:organization, :seller, name: "Vegetable Farms", markets: [market2]) }
    let!(:market2_seller4) { create(:organization, :seller, name: "Smith Farms", markets: [market2]) }
    let!(:market2_buyer)  { create(:organization, :buyer, name: "Institution", markets: [market2]) }

    let!(:market2_product1) { create(:product, :sellable, organization: market2_seller1) }
    let!(:market2_product2) { create(:product, :sellable, organization: market2_seller2) }
    let!(:market2_product3) { create(:product, :sellable, organization: market2_seller2) }
    let!(:market2_product4) { create(:product, :sellable, organization: market2_seller3) }

    let!(:market2_order1) { create(:order, items:[create(:order_item, :delivered, product: market2_product1, quantity: 4)], market: market2, organization: market2_buyer, delivery: market2_delivery, payment_method: "purchase order", order_number: "LO-006", total_cost: 27.96, placed_at: 19.days.ago) }
    let!(:market2_order2) { create(:order, items:[create(:order_item, :delivered, product: market2_product2, quantity: 3), create(:order_item, :delivered, product: market2_product4, quantity: 7)], market: market2, organization: market2_buyer, delivery: market2_delivery, payment_method: "purchase order", order_number: "LO-007", total_cost: 69.90, placed_at: 6.days.ago, payment_status: "paid") }
    let!(:market2_order3) { create(:order, items:[create(:order_item, :delivered, product: market2_product3, quantity: 6)], market: market2, organization: market2_buyer, delivery: market2_delivery, payment_method: "purchase order", order_number: "LO-0008", total_cost: 41.94, placed_at: 4.days.ago) }
    let!(:market2_order4) { create(:order, items:[create(:order_item, :delivered, product: market2_product2, quantity: 9), create(:order_item, :delivered, product: market2_product3, quantity: 14)], market: market2, organization: market2_buyer, delivery: market2_delivery, payment_method: "purchase order", order_number: "LO-009", total_cost: 160.77, placed_at: 3.days.ago) }


    scenario "filtering by market" do
      switch_to_subdomain(market1.subdomain)
      sign_in_as market_manager
      visit admin_financials_vendor_payments_path

      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
      expect(seller_rows.map {|r| r.name.text }).to eq(["Best Farms", "Better Farms", "Betterest Farms", "Fruit Farms", "Great Farms", "Vegetable Farms"])

      within("#q_market_id_eq") do
        expect(page).to have_content(market1.name)
        expect(page).to have_content(market2.name)
      end

      select market1.name, from: "q_market_id_eq"
      click_button "Filter"

      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
      expect(seller_rows.map {|r| r.name.text }).to eq(["Better Farms", "Betterest Farms", "Great Farms"])

      within("#q_product_products_organization_id_eq") do
        expect(page).to have_content(market1_seller1.name)
        expect(page).to have_content(market1_seller2.name)
        expect(page).to have_content(market1_seller3.name)
        expect(page).to have_content(market1_seller4.name)
        expect(page).not_to have_content(market2_seller1.name)
        expect(page).not_to have_content(market2_seller2.name)
        expect(page).not_to have_content(market2_seller3.name)
        expect(page).not_to have_content(market2_seller4.name)
      end

      select market2.name, from: "q_market_id_eq"
      click_button "Filter"

      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
      expect(seller_rows.map {|r| r.name.text }).to eq(["Best Farms", "Fruit Farms", "Vegetable Farms"])
      within("#q_products_organization_id_eq") do
        expect(page).not_to have_content(market1_seller1.name)
        expect(page).not_to have_content(market1_seller2.name)
        expect(page).not_to have_content(market1_seller3.name)
        expect(page).not_to have_content(market1_seller4.name)
        expect(page).to have_content(market2_seller1.name)
        expect(page).to have_content(market2_seller2.name)
        expect(page).to have_content(market2_seller3.name)
        expect(page).to have_content(market2_seller4.name)
      end
    end

    scenario "filtering by organization" do
      switch_to_subdomain(market1.subdomain)
      sign_in_as market_manager
      visit admin_financials_vendor_payments_path

      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
      expect(seller_rows.map {|r| r.name.text }).to eq(["Best Farms", "Better Farms", "Betterest Farms", "Fruit Farms", "Great Farms", "Vegetable Farms"])

      within("#q_products_organization_id_eq") do
        expect(page).to have_content(market1_seller1.name)
        expect(page).to have_content(market1_seller2.name)
        expect(page).to have_content(market1_seller3.name)
        expect(page).to have_content(market1_seller4.name)
        expect(page).to have_content(market2_seller1.name)
        expect(page).to have_content(market2_seller2.name)
        expect(page).to have_content(market2_seller3.name)
        expect(page).to have_content(market2_seller4.name)
      end

      select market1_seller1.name, from: "q_products_organization_id_eq"
      click_button "Filter"

      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
      expect(seller_rows.map {|r| r.name.text }).to eq(["Better Farms"])

      select market1_seller3.name, from: "q_products_organization_id_eq"
      click_button "Filter"

      seller_rows = Dom::Admin::Financials::VendorPaymentRow.all
      expect(seller_rows.map {|r| r.name.text }).to eq(["Betterest Farms", "Great Farms"])
    end

    scenario "filtering by payment type"
  end
end
