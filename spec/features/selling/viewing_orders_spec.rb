require 'spec_helper'

feature "Viewing orders" do
  let!(:market1)          { create(:market, market_seller_fee: 5, local_orbit_seller_fee: 4)}
  let!(:market1_delivery_schedule) { create(:delivery_schedule, market: market1, day: 2, fee: 7.12, fee_type: 'fixed') }
  let!(:market1_delivery)        { market1.delivery_schedules.first.next_delivery }

  let!(:market1_seller_org1) { create(:organization, :seller, markets: [market1]) }
  let!(:market1_seller_org2) { create(:organization, :seller, markets: [market1]) }
  let!(:market1_buyer_org1)   { create(:organization, :buyer,  markets: [market1]) }
  let!(:market1_buyer_org2)   { create(:organization, :buyer,  markets: [market1]) }
  let!(:market1_product1)    { create(:product, :sellable, organization: market1_seller_org1) }
  let!(:market1_product2)    { create(:product, :sellable, organization: market1_seller_org2) }

  let!(:market1_order_item1) { create(:order_item, seller_name: market1_seller_org1.name, product: market1_product1, quantity: 2, unit_price: 4.99, market_seller_fee: 0.50, local_orbit_seller_fee: 0.40) }
  let!(:market1_order_item2) { create(:order_item, seller_name: market1_seller_org2.name, product: market1_product2, quantity: 2, unit_price: 8.99, market_seller_fee: 0.90, local_orbit_seller_fee: 0.72) }
  let!(:market1_order1)      { create(:order, items: [market1_order_item1, market1_order_item2], organization: market1_buyer_org1, market: market1, total_cost: 27.96, delivery: market1_delivery, placed_at: Date.parse("May 10, 2014")) }

  let!(:market1_order_item3) { create(:order_item, seller_name: market1_seller_org1.name, product: market1_product1, quantity: 2, unit_price: 8.99, market_seller_fee: 0.90, local_orbit_seller_fee: 0.72) }
  let!(:market1_order_item4) { create(:order_item, seller_name: market1_seller_org2.name, product: market1_product2, quantity: 3, unit_price: 7.99, market_seller_fee: 1.20, local_orbit_seller_fee: 0.96) }
  let!(:market1_order2)      { create(:order, items: [market1_order_item3, market1_order_item4], organization: market1_buyer_org2, market: market1, total_cost: 41.95, delivery: market1_delivery, placed_at: Date.parse("May 11, 2014")) }

  let!(:market1_order_item5) { create(:order_item, seller_name: market1_seller_org2, product: market1_product2) }
  let!(:market1_order3)      { create(:order, items: [market1_order_item5], organization: market1_buyer_org1, market: market1, delivery: market1_delivery, placed_at: Date.parse("May 12, 2014")) }

  let!(:market2)          { create(:market, :with_delivery_schedule, market_seller_fee: 5, local_orbit_seller_fee: 4)}
  let!(:market2_delivery)        { market2.delivery_schedules.first.next_delivery }

  let!(:market2_seller_org1) { create(:organization, :seller, markets: [market2]) }
  let!(:market2_seller_org2) { create(:organization, :seller, markets: [market2]) }
  let!(:market2_buyer_org)   { create(:organization, :buyer,  markets: [market2]) }
  let!(:market2_product1)    { create(:product, :sellable, organization: market2_seller_org1) }
  let!(:market2_product2)    { create(:product, :sellable, organization: market2_seller_org2) }

  let!(:market2_order_item1) { create(:order_item, seller_name: market2_seller_org1.name, product: market2_product1, quantity: 2, unit_price: 4.99, market_seller_fee: 0.50, local_orbit_seller_fee: 0.40) }
  let!(:market2_order_item2) { create(:order_item, seller_name: market2_seller_org2.name, product: market2_product2, quantity: 2, unit_price: 8.99, market_seller_fee: 0.90, local_orbit_seller_fee: 0.72) }
  let!(:market2_order1)      { create(:order, items: [market2_order_item1, market2_order_item2], organization: market2_buyer_org, market: market2, total_cost: 27.96, delivery: market2_delivery, placed_at: Date.parse("May 13, 2014")) }

  let!(:market2_order_item3) { create(:order_item, seller_name: market2_seller_org1.name, product: market2_product1, quantity: 2, unit_price: 8.99, market_seller_fee: 0.90, local_orbit_seller_fee: 0.72) }
  let!(:market2_order_item4) { create(:order_item, seller_name: market2_seller_org2.name, product: market2_product2, quantity: 3, unit_price: 7.99, market_seller_fee: 1.20, local_orbit_seller_fee: 0.96) }
  let!(:market2_order2)      { create(:order, items: [market2_order_item3, market2_order_item4], organization: market2_buyer_org, market: market2, total_cost: 41.95, delivery: market2_delivery, placed_at: Date.parse("May 14, 2014")) }

  let!(:market2_order_item5) { create(:order_item, seller_name: market2_seller_org2.name,  product: market2_product2, payment_seller_fee: 0.50) }
  let!(:market2_order3)      { create(:order, items: [market2_order_item5], organization: market2_buyer_org, market: market2, delivery: market2_delivery, placed_at: Date.parse("May 15, 2014")) }

  context "as a seller" do
    let!(:user) { create(:user, organizations: [market1_seller_org1]) }

    before do
      switch_to_subdomain(market1.subdomain)
      sign_in_as(user)
    end

    scenario "lists all orders for markets a user can manage" do
      visit admin_orders_path

      orders = Dom::Admin::OrderRow.all
      expect(orders.count).to eq(2)

      order = Dom::Admin::OrderRow.find_by_order_number(market1_order1.order_number)
      expect(order.amount_owed).to eq("$9.98")
      expect(order.delivery_status).to eq('Pending')
      expect(order.buyer_status).to eq('Unpaid')

      order = Dom::Admin::OrderRow.find_by_order_number(market1_order2.order_number)
      expect(order.amount_owed).to eq("$17.98")
      expect(order.delivery_status).to eq('Pending')
      expect(order.buyer_status).to eq('Unpaid')
    end

    scenario "order details" do
      visit admin_orders_path

      click_link market1_order1.order_number

      expect(page).to have_content("Order info")
      expect(page).to have_content(market1_order1.organization.name)
      expect(page).to have_content("$9.98")
      expect(page).to have_content("Purchase Order")
      expect(page).to_not have_content("Delivery Fees: $7.12")

      items = Dom::Order::ItemRow.all
      expect(items.count).to eq(1)

      item = Dom::Order::ItemRow.first
      expect(item.name).to have_content(market1_order_item1.name)
      expect(item.quantity).to have_content(market1_order_item1.quantity.to_s)
      expect(item.price).to eq("$#{market1_order_item1.unit_price}")
      expect(item.discount).to eq('$0.00')
      expect(item.total).to eq("$9.98")
      expect(item.payment_status).to eq("Unpaid")

      summary = Dom::Admin::OrderSummaryRow.first
      expect(summary.gross_total).to eq("$9.98")
      expect(summary.discount).to eq("$0.00")
      expect(summary.market_fees).to eq("$0.50")
      expect(summary.transaction_fees).to eq("$0.40")
      expect(summary.payment_processing).to eq("$0.00")
      expect(summary.net_sale).to eq("$9.08")
    end
  end

  context "as a market_manager" do
    let!(:user) { create(:user, managed_markets: [market1, market2]) }

    before do
      switch_to_subdomain(market1.subdomain)
      sign_in_as(user)
    end

    scenario "list of orders" do
      visit admin_orders_path

      orders = Dom::Admin::OrderRow.all
      expect(orders.count).to eq(6)

      order = Dom::Admin::OrderRow.find_by_order_number(market1_order1.order_number)
      expect(order.amount_owed).to eq("$27.96")
      expect(order.delivery_status).to eq('Pending')
      expect(order.buyer_status).to eq('Unpaid')

      order = Dom::Admin::OrderRow.find_by_order_number(market1_order2.order_number)
      expect(order.amount_owed).to eq("$41.95")
      expect(order.delivery_status).to eq('Pending')
      expect(order.buyer_status).to eq('Unpaid')
    end

    scenario "order details" do
      visit admin_orders_path

      click_link market1_order1.order_number

      expect(page).to have_content("Order info")
      expect(page).to have_content(market1_order1.organization.name)
      expect(page).to have_content("$9.98")
      expect(page).to have_content("Purchase Order")
      expect(page).to have_content("Delivery Fees: $7.12")

      items = Dom::Order::ItemRow.all
      expect(items.count).to eq(2)

      item = Dom::Order::ItemRow.find_by_name("#{market1_order_item1.name} from #{market1_seller_org1.name}")
      expect(item.price).to eq("$#{market1_order_item1.unit_price}")
      expect(item.discount).to eq('$0.00')
      expect(item.total).to eq("$9.98")
      expect(item.payment_status).to eq("Unpaid")

      item = Dom::Order::ItemRow.find_by_name("#{market1_order_item2.name} from #{market1_seller_org2.name}")
      expect(item.price).to eq("$#{market1_order_item2.unit_price}")
      expect(item.discount).to eq('$0.00')
      expect(item.total).to eq("$17.98")
      expect(item.payment_status).to eq("Unpaid")

      summary = Dom::Admin::OrderSummaryRow.first
      expect(summary.gross_total).to eq("$27.96")
      expect(summary.discount).to eq("$0.00")
      expect(summary.market_fees).to eq("$1.40")
      expect(summary.transaction_fees).to eq("$1.12")
      expect(summary.payment_processing).to eq("$0.00")
      expect(summary.net_sale).to eq("$25.44")
    end

    context "when a user only has one market" do
      let!(:user) { create(:user, managed_markets: [market1]) }

      scenario "they don't see an option to filter by a market" do
        visit admin_orders_path
        expect(page).not_to have_select("Market")
      end
    end

    scenario "filtering a list of orders by market" do
      visit admin_orders_path

      expect(page).to have_select("Market")

      within("#q_organization_id_eq") do
        expect(page).to have_content(market1_buyer_org1.name)
        expect(page).to have_content(market1_buyer_org2.name)
        expect(page).to have_content(market2_buyer_org.name)
      end

      expect(page).to have_content(market1_order1.order_number)
      expect(page).to have_content(market1_order2.order_number)
      expect(page).to have_content(market1_order3.order_number)
      expect(page).to have_content(market2_order1.order_number)
      expect(page).to have_content(market2_order2.order_number)
      expect(page).to have_content(market2_order3.order_number)

      select market1.name, from: "q_market_id_eq"
      click_button "Filter"

      expect(page).to have_content(market1_order1.order_number)
      expect(page).to have_content(market1_order2.order_number)
      expect(page).to have_content(market1_order3.order_number)
      expect(page).not_to have_content(market2_order1.order_number)
      expect(page).not_to have_content(market2_order2.order_number)
      expect(page).not_to have_content(market2_order3.order_number)

      within("#q_organization_id_eq") do
        expect(page).to have_content(market1_buyer_org1.name)
        expect(page).to have_content(market1_buyer_org2.name)
        expect(page).not_to have_content(market2_buyer_org.name)
      end

      expect(find(:css, "#q_market_id_eq").value).to eql(market1.id.to_s)
    end

    scenario "filtering list of orders by buyer" do
      visit admin_orders_path

      expect(page).to have_content(market1_order1.order_number)
      expect(page).to have_content(market1_order2.order_number)
      expect(page).to have_content(market1_order3.order_number)
      expect(page).to have_content(market2_order1.order_number)
      expect(page).to have_content(market2_order2.order_number)
      expect(page).to have_content(market2_order3.order_number)

      select market1_buyer_org1.name, from: "q_organization_id_eq"
      click_button "Filter"

      expect(page).to have_content(market1_order1.order_number)
      expect(page).not_to have_content(market1_order2.order_number)
      expect(page).to have_content(market1_order3.order_number)
      expect(page).not_to have_content(market2_order1.order_number)
      expect(page).not_to have_content(market2_order2.order_number)
      expect(page).not_to have_content(market2_order3.order_number)
    end

    scenario "filtering list of orders by order date" do
      visit admin_orders_path

      expect(page).to have_content(market1_order1.order_number)
      expect(page).to have_content(market1_order2.order_number)
      expect(page).to have_content(market1_order3.order_number)
      expect(page).to have_content(market2_order1.order_number)
      expect(page).to have_content(market2_order2.order_number)
      expect(page).to have_content(market2_order3.order_number)

      fill_in "q_placed_at_date_gteq", with: "Mon, 12 May 2014"
      click_button "Filter"

      expect(page).not_to have_content(market1_order1.order_number)
      expect(page).not_to have_content(market1_order2.order_number)
      expect(page).to have_content(market1_order3.order_number)
      expect(page).to have_content(market2_order1.order_number)
      expect(page).to have_content(market2_order2.order_number)
      expect(page).to have_content(market2_order3.order_number)

      fill_in "q_placed_at_date_lteq", with: "Mon, 14 May 2014"
      click_button "Filter"

      expect(page).not_to have_content(market1_order1.order_number)
      expect(page).not_to have_content(market1_order2.order_number)
      expect(page).to have_content(market1_order3.order_number)
      expect(page).to have_content(market2_order1.order_number)
      expect(page).to have_content(market2_order2.order_number)
      expect(page).not_to have_content(market2_order3.order_number)
    end

    scenario "filtering list of orders by order number" do
      visit admin_orders_path

      expect(page).to have_content(market1_order1.order_number)
      expect(page).to have_content(market1_order2.order_number)
      expect(page).to have_content(market1_order3.order_number)
      expect(page).to have_content(market2_order1.order_number)
      expect(page).to have_content(market2_order2.order_number)
      expect(page).to have_content(market2_order3.order_number)

      fill_in "q_order_number_or_organization_name_or_items_seller_name_cont", with: market1_order3.order_number
      click_button "Filter"

      expect(page).not_to have_content(market1_order1.order_number)
      expect(page).not_to have_content(market1_order2.order_number)
      expect(page).to have_content(market1_order3.order_number)
      expect(page).not_to have_content(market2_order1.order_number)
      expect(page).not_to have_content(market2_order2.order_number)
      expect(page).not_to have_content(market2_order3.order_number)
    end

    scenario "filtering list of orders by buyer" do
      visit admin_orders_path

      expect(page).to have_content(market1_order1.order_number)
      expect(page).to have_content(market1_order2.order_number)
      expect(page).to have_content(market1_order3.order_number)
      expect(page).to have_content(market2_order1.order_number)
      expect(page).to have_content(market2_order2.order_number)
      expect(page).to have_content(market2_order3.order_number)

      fill_in "q_order_number_or_organization_name_or_items_seller_name_cont", with: market1_buyer_org1.name
      click_button "Filter"

      expect(page).to have_content(market1_order1.order_number)
      expect(page).not_to have_content(market1_order2.order_number)
      expect(page).to have_content(market1_order3.order_number)
      expect(page).not_to have_content(market2_order1.order_number)
      expect(page).not_to have_content(market2_order2.order_number)
      expect(page).not_to have_content(market2_order3.order_number)
    end

    scenario "filtering list of orders by seller" do
      visit admin_orders_path

      expect(page).to have_content(market1_order1.order_number)
      expect(page).to have_content(market1_order2.order_number)
      expect(page).to have_content(market1_order3.order_number)
      expect(page).to have_content(market2_order1.order_number)
      expect(page).to have_content(market2_order2.order_number)
      expect(page).to have_content(market2_order3.order_number)

      fill_in "q_order_number_or_organization_name_or_items_seller_name_cont", with: market1_seller_org1.name
      click_button "Filter"

      expect(page).to have_content(market1_order1.order_number)
      expect(page).to have_content(market1_order2.order_number)
      expect(page).not_to have_content(market1_order3.order_number)
      expect(page).not_to have_content(market2_order1.order_number)
      expect(page).not_to have_content(market2_order2.order_number)
      expect(page).not_to have_content(market2_order3.order_number)
    end

    it "displays sales order totals for all pages of filtered results" do
      visit admin_orders_path(per_page: 2)

      find(".pagination")

      totals = Dom::Admin::TotalSales.first

      expect(totals.gross_sales).to eq("$153.80")
      expect(totals.market_fees).to eq("$7.00")
      expect(totals.lo_fees).to eq("$5.60")
      expect(totals.processing_fees).to eq("$0.50")
      expect(totals.discounts).to eq("$0.00")
      expect(totals.net_sales).to eq("$140.70")

      select market1_buyer_org1.name, from: "q_organization_id_eq"
      click_button "Filter"

      totals = Dom::Admin::TotalSales.first

      expect(totals.gross_sales).to eq("$34.95")
      expect(totals.market_fees).to eq("$1.40")
      expect(totals.lo_fees).to eq("$1.12")
      expect(totals.processing_fees).to eq("$0.00")
      expect(totals.discounts).to eq("$0.00")
      expect(totals.net_sales).to eq("$32.43")
    end
  end
end
