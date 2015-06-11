require "spec_helper"

feature "Viewing orders" do
  let!(:market1)                   { create(:market, market_seller_fee: 5, local_orbit_seller_fee: 4) }
  let!(:market1_delivery_schedule) { create(:delivery_schedule, market: market1, day: 2, fee: 7.12, fee_type: "fixed") }
  let!(:market1_delivery)          { market1.delivery_schedules.first.next_delivery }

  let!(:market1_seller_org1) { create(:organization, :seller, markets: [market1]) }
  let!(:market1_seller_org2) { create(:organization, :seller, markets: [market1]) }
  let!(:market1_buyer_org1)  { create(:organization, :buyer,  markets: [market1]) }
  let!(:market1_buyer_org2)  { create(:organization, :buyer,  markets: [market1]) }
  let!(:market1_product1)    { create(:product, :sellable, organization: market1_seller_org1) }
  let!(:market1_product2)    { create(:product, :sellable, organization: market1_seller_org2) }

  let(:discount_seller) { "2.51".to_d }
  let(:discount_market) { "1.05".to_d }
  let!(:market1_order_item1) { create(:order_item, seller_name: market1_seller_org1.name, product: market1_product1, quantity: 2, unit_price: 4.99, market_seller_fee: 0.50, local_orbit_seller_fee: 0.40, delivery_status: "delivered", discount_seller: discount_seller, discount_market: discount_market) }
  let!(:market1_order_item2) { create(:order_item, seller_name: market1_seller_org2.name, product: market1_product2, quantity: 2, unit_price: 8.99, market_seller_fee: 0.90, local_orbit_seller_fee: 0.72, delivery_status: "pending") }
  let!(:market1_order1)      { create(:order, items: [market1_order_item1, market1_order_item2], organization: market1_buyer_org1, market: market1, total_cost: 35.08, delivery: market1_delivery, delivery_fees: 7.12, placed_at: 2.weeks.ago) }

  let!(:market1_order_item3) { create(:order_item, seller_name: market1_seller_org1.name, product: market1_product1, quantity: 2, unit_price: 8.99, market_seller_fee: 0.90, local_orbit_seller_fee: 0.72) }
  let!(:market1_order_item4) { create(:order_item, seller_name: market1_seller_org2.name, product: market1_product2, quantity: 3, unit_price: 7.99, market_seller_fee: 1.20, local_orbit_seller_fee: 0.96) }
  let!(:market1_order2)      { create(:order, items: [market1_order_item3, market1_order_item4], organization: market1_buyer_org2, market: market1, total_cost: 49.07, delivery: market1_delivery, delivery_fees: 7.12, placed_at: 2.weeks.ago) }

  let!(:market1_order_item5) { create(:order_item, seller_name: market1_seller_org2, product: market1_product2) }
  let!(:market1_order3)      { create(:order, items: [market1_order_item5], organization: market1_buyer_org1, market: market1, total_cost: market1_order_item5.gross_total + 7.12, delivery_fees: 7.12, delivery: market1_delivery) }

  let!(:market2)          { create(:market, :with_delivery_schedule, market_seller_fee: 5, local_orbit_seller_fee: 4) }
  let!(:market2_delivery) { market2.delivery_schedules.first.next_delivery }

  let!(:market2_seller_org1) { create(:organization, :seller, markets: [market2]) }
  let!(:market2_seller_org2) { create(:organization, :seller, markets: [market2]) }
  let!(:market2_buyer_org)   { create(:organization, :buyer,  markets: [market2]) }
  let!(:market2_product1)    { create(:product, :sellable, organization: market2_seller_org1) }
  let!(:market2_product2)    { create(:product, :sellable, organization: market2_seller_org2) }

  let!(:market2_order_item1) { create(:order_item, seller_name: market2_seller_org1.name, product: market2_product1, quantity: 2, unit_price: 4.99, market_seller_fee: 0.50, local_orbit_seller_fee: 0.40) }
  let!(:market2_order_item2) { create(:order_item, seller_name: market2_seller_org2.name, product: market2_product2, quantity: 2, unit_price: 8.99, market_seller_fee: 0.90, local_orbit_seller_fee: 0.72) }
  let!(:market2_order1)      { create(:order, items: [market2_order_item1, market2_order_item2], organization: market2_buyer_org, market: market2, total_cost: 27.96, delivery: market2_delivery) }

  let!(:market2_order_item3) { create(:order_item, seller_name: market2_seller_org1.name, product: market2_product1, quantity: 2, unit_price: 8.99, market_seller_fee: 0.90, local_orbit_seller_fee: 0.72) }
  let!(:market2_order_item4) { create(:order_item, seller_name: market2_seller_org2.name, product: market2_product2, quantity: 3, unit_price: 7.99, market_seller_fee: 1.20, local_orbit_seller_fee: 0.96) }
  let!(:market2_order2)      { create(:order, items: [market2_order_item3, market2_order_item4], organization: market2_buyer_org, market: market2, total_cost: 41.95, delivery: market2_delivery) }

  let!(:market2_order_item5) { create(:order_item, seller_name: market2_seller_org2.name,  product: market2_product2, payment_seller_fee: 0.50) }
  let!(:market2_order3)      { create(:order, items: [market2_order_item5], organization: market2_buyer_org, market: market2, total_cost: market2_order_item5.gross_total, delivery: market2_delivery) }

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
      expect(order.delivery_status).to eq("Delivered")
      expect(order.buyer_name).to eql(market1_buyer_org1.name)
      expect(order.buyer_status).to eq("Unpaid")

      order = Dom::Admin::OrderRow.find_by_order_number(market1_order2.order_number)
      expect(order.amount_owed).to eq("$17.98")
      expect(order.delivery_status).to eq("Pending")
      expect(order.buyer_name).to eql(market1_buyer_org2.name)
      expect(order.buyer_status).to eq("Unpaid")

      totals = Dom::Admin::TotalSales.first

      expect(totals.gross_sales).to eq("$27.96")
      expect(totals.market_fees).to eq("$1.40")
      expect(totals.lo_fees).to eq("$1.12")
      expect(totals.processing_fees).to eq("$0.00")
      expect(totals.discounts).to eq("$2.51")
      expect(totals.net_sales).to eq("$#{25.44 - discount_seller}")
    end

    scenario "order details" do
      visit admin_orders_path

      click_link market1_order1.order_number

      expect(page).to have_content("Order info")
      expect(page).to have_content(market1_order1.organization.name)
      expect(page).to have_content("$9.98")
      expect(page).to have_content("Purchase Order")
      expect(page).to have_content("Delivery Status: Delivered")
      expect(page).to_not have_content("Delivery Fees: $7.12")

      items = Dom::Order::ItemRow.all
      expect(items.count).to eq(1)

      item = Dom::Order::ItemRow.first
      expect(item.name).to have_content(market1_order_item1.name)
      expect(item.quantity).to have_content(market1_order_item1.quantity.to_s)
      expect(item.price).to eq("$#{market1_order_item1.unit_price}")
      expect(item.has_discount?).to be false
      expect(item.total).to eq("$9.98")
      expect(item.payment_status).to eq("Unpaid")

      summary = Dom::Admin::OrderSummaryRow.first
      expect(summary.gross_total).to eq("$9.98")
      expect(summary.discount).to eq("$#{discount_seller}") 
      expect(summary.market_fees).to eq("$0.50")
      expect(summary.transaction_fees).to eq("$0.40")
      expect(summary.payment_processing).to eq("$0.00")
      expect(summary.net_sale).to eq("$#{9.08-discount_seller}")
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
      expect(order.delivery_status).to eq("Partially Delivered")
      expect(order.buyer_name).to eql(market1_buyer_org1.name)
      expect(order.buyer_status).to eq("Unpaid")

      order = Dom::Admin::OrderRow.find_by_order_number(market1_order2.order_number)
      expect(order.amount_owed).to eq("$41.95")
      expect(order.delivery_status).to eq("Pending")
      expect(order.buyer_name).to eql(market1_buyer_org2.name)
      expect(order.buyer_status).to eq("Unpaid")
    end

    scenario "list of orders after the market manager deletes an organization" do
      delete_organization(market1_seller_org1)
      delete_organization(market1_seller_org2)

      visit admin_orders_path

      orders = Dom::Admin::OrderRow.all
      expect(orders.count).to eq(6)

      order = Dom::Admin::OrderRow.find_by_order_number(market1_order1.order_number)
      expect(order.amount_owed).to eq("$27.96")
      expect(order.delivery_status).to eq("Partially Delivered")
      expect(order.buyer_status).to eq("Unpaid")

      order = Dom::Admin::OrderRow.find_by_order_number(market1_order2.order_number)
      expect(order.amount_owed).to eq("$41.95")
      expect(order.delivery_status).to eq("Pending")
      expect(order.buyer_status).to eq("Unpaid")
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
      expect(item.has_discount?).to be false
      expect(item.total).to eq("$9.98")
      expect(item.payment_status).to eq("Unpaid")

      item = Dom::Order::ItemRow.find_by_name("#{market1_order_item2.name} from #{market1_seller_org2.name}")
      expect(item.price).to eq("$#{market1_order_item2.unit_price}")
      expect(item.has_discount?).to be false
      expect(item.total).to eq("$17.98")
      expect(item.payment_status).to eq("Unpaid")

      summary = Dom::Admin::OrderSummaryRow.first
      expect(summary.gross_total).to eq("$27.96")

      #expect(summary.discount_seller).to eq("$#{discount_seller}")
      expect(summary.discount_market).to eq("$#{discount_market}")
      expect(summary.market_fees).to eq("$1.40")
      expect(summary.transaction_fees).to eq("$1.12")
      expect(summary.payment_processing).to eq("$0.00")
      expect(summary.net_sale).to eq("$25.44")
    end

    context "market manager deletes an organization" do
      let!(:market_manager) { create(:user, managed_markets: [market1]) }
      before do
        switch_user(market_manager) do
          delete_organization(market1_seller_org1)
          delete_organization(market1_seller_org2)
        end
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
        expect(item.has_discount?).to be false
        expect(item.total).to eq("$9.98")
        expect(item.payment_status).to eq("Unpaid")

        item = Dom::Order::ItemRow.find_by_name("#{market1_order_item2.name} from #{market1_seller_org2.name}")
        expect(item.price).to eq("$#{market1_order_item2.unit_price}")
        expect(item.has_discount?).to be false
        expect(item.total).to eq("$17.98")
        expect(item.payment_status).to eq("Unpaid")

        summary = Dom::Admin::OrderSummaryRow.first
        expect(summary.gross_total).to eq("$27.96")

        #expect(summary.discount_seller).to eq("$#{discount_seller}")
        expect(summary.discount_market).to eq("$#{discount_market}")
        expect(summary.market_fees).to eq("$1.40")
        expect(summary.transaction_fees).to eq("$1.12")
        expect(summary.payment_processing).to eq("$0.00")
        expect(summary.net_sale).to eq("$25.44")
      end
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

    scenario "filter orders by order date with past month default or other range" do
      market2_order2.update_attributes(placed_at: 5.weeks.ago)
      market2_order3.update_attributes(placed_at: 7.weeks.ago)

      visit admin_orders_path

      # Tests default date filter of the past month
      expect(page).to have_content(market1_order1.order_number)
      expect(page).to have_content(market1_order2.order_number)
      expect(page).to have_content(market1_order3.order_number)
      expect(page).to have_content(market2_order1.order_number)
      expect(page).not_to have_content(market2_order2.order_number)
      expect(page).not_to have_content(market2_order3.order_number)

      fill_in "q_placed_at_date_gteq", with: 7.weeks.ago.to_date.to_s
      fill_in "q_placed_at_date_lteq", with: 5.weeks.ago.to_date.to_s
      click_button "Filter"

      expect(page).not_to have_content(market1_order1.order_number)
      expect(page).not_to have_content(market1_order2.order_number)
      expect(page).not_to have_content(market1_order3.order_number)
      expect(page).not_to have_content(market2_order1.order_number)
      expect(page).to have_content(market2_order2.order_number)
      expect(page).to have_content(market2_order3.order_number)

      fill_in "q_placed_at_date_lteq", with: 6.weeks.ago.to_date.to_s
      click_button "Filter"

      expect(page).not_to have_content(market1_order1.order_number)
      expect(page).not_to have_content(market1_order2.order_number)
      expect(page).not_to have_content(market1_order3.order_number)
      expect(page).not_to have_content(market2_order1.order_number)
      expect(page).not_to have_content(market2_order2.order_number)
      expect(page).to have_content(market2_order3.order_number)
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
      expect(totals.discounts).to eq("$#{discount_seller}") # Seller orders, should see seller discount amount 
      expect(totals.net_sales).to eq("$#{140.70.to_d - discount_seller}")

      select market1_buyer_org1.name, from: "q_organization_id_eq"
      click_button "Filter"

      totals = Dom::Admin::TotalSales.first

      expect(totals.gross_sales).to eq("$34.95")
      expect(totals.market_fees).to eq("$1.40")
      expect(totals.lo_fees).to eq("$1.12")
      expect(totals.processing_fees).to eq("$0.00")
      expect(totals.discounts).to eq("$#{discount_seller + discount_market}") # fails - which should this be
      expect(totals.net_sales).to eq("$#{32.43.to_d - discount_seller}")
    end
  end

  context "as an admin" do
    let(:user) { create(:user, role: "admin") }

    before do
      switch_to_subdomain(market1.subdomain)
      sign_in_as(user)
    end

    context "searching with an order number" do
      it "only shows unique results" do
        visit admin_orders_path

        fill_in "Search Orders", with: market1_order1.order_number
        click_button "Search"

        items = Dom::Dashboard::OrderRow.all
        expect(items.count).to eql(1)

        fill_in "Search Orders", with: market1_order2.order_number
        click_button "Search"

        items = Dom::Dashboard::OrderRow.all
        expect(items.count).to eql(1)
      end
    end
  end
end
