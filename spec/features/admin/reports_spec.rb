require "spec_helper"

def display_date(date)
  date.strftime("%m/%d/%Y")
end

feature "Reports", :js do
  let!(:market)    { create(:market, name: "Foo Market", po_payment_term: 30, timezone: "Eastern Time (US & Canada)") }
  let!(:market2)   { create(:market, name: "Bar Market", po_payment_term: 30, timezone: "Eastern Time (US & Canada)") }
  let!(:market3)   { create(:market, name: "Baz Market", po_payment_term: 30, timezone: "Eastern Time (US & Canada)") }

  let!(:buyer)     { create(:organization, :buyer, markets: [market], name: "Foo Buyer", can_sell: false) }
  let!(:buyer2)    { create(:organization, :buyer, markets: [market2], name: "Bar Buyer", can_sell: false) }
  let!(:seller)    { create(:organization, :seller, markets: [market], name: "Foo Seller", can_sell: true) }
  let!(:seller2)   { create(:organization, :seller, markets: [market2], name: "Bar Seller", can_sell: true) }

  let!(:subdomain) { market.subdomain }
  let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
  let!(:delivery)  { delivery_schedule.next_delivery }
  let!(:order_date) { 3.weeks.ago }

  before do
    delivery_schedule2 = create(:delivery_schedule, market: market2)
    delivery2 = delivery_schedule2.next_delivery

    buyer3  = create(:organization, :buyer, name: "Baz Buyer", markets: [market3], can_sell: false)
    seller3  = create(:organization, :seller, name: "Baz Seller", markets: [market3], can_sell: true)

    5.times do |i|
      this_date = order_date + i.days
      Timecop.freeze(this_date) do
        p_category = create(:category, name: 'Parent')
        category = create(:category, name: "Category-01-#{i}", parent_id: p_category.id)
        product = create(:product,
                         :sellable,
                         name: "Product#{i}",
                         category: category,
                         organization: seller,
                         code: "product-code-#{i}")
        order_item = create(:order_item,
                            product: product,
                            seller_name: seller.name,
                            unit_price: 20.00 + i, quantity: 1,
                            market_seller_fee: 0.50,
                            payment_seller_fee: 1.25
        )
        order = create(:order,
                       market_id: market.id,
                       delivery: delivery,
                       items: [order_item],
                       organization: buyer,
                       delivery_fees: 1,
                       payment_method: ["purchase order", "purchase order", "purchase order", "ach", "ach", "credit card"][i],
                       payment_note: ["PURCHASE-0-foo", "PURCHASE-1-foo", nil, nil, nil, nil][i],
                       payment_status: "paid",
                       order_number: "LO-01-234-4567890-#{i}")
        create(:payment,
               payment_method: ["cash", "check", "ach", "ach", "credit card"][i],
               payer: buyer,
               payee: market,
               orders: [order],
               amount: order.total_cost)

        category = create(:category, name: "Category-02-#{i}")
        product = create(:product,
                         :sellable,
                         name: "Product#{i}",
                         category: category,
                         organization: seller2,
                         code: "product-code-#{i}")
        order_item = create(:order_item,
                            product: product,
                            seller_name: seller2.name,
                            unit_price: 20.00 + i, quantity: 1)
        create(:order,
               market_id: market2.id,
               delivery: delivery2,
               items: [order_item],
               organization: buyer2,
               payment_method: ["purchase order", "purchase order", "purchase order", "ach", "ach", "credit card"][i],
               payment_status: "paid",
               order_number: "LO-02-234-4567890-#{i}")
      end
    end

    this_date = order_date - 1.day
    order_item = create(:order_item,
                        product: create(:product, :sellable, organization: seller3),
                        created_at: this_date,
                        seller_name: "Seller-03-1",
                        unit_price: 301, quantity: 1)
    create(:order,
           placed_at: this_date,
           delivery: delivery,
           items: [order_item],
           organization: buyer3,
           payment_method: "credit card",
           payment_status: "unpaid",
           order_number: "LO-03-234-4567890-1")

    # Order outside of default date range
    older_date = 5.weeks.ago
    create(:order,
           placed_at: older_date,
           delivery: delivery,
           items: [create(:order_item, product: create(:product, :sellable, organization: seller3), created_at: older_date)],
           organization: buyer3,
           payment_method: "credit card",
           payment_status: "unpaid",
           order_number: "LO-03-234-4567890-2")

    switch_to_subdomain(subdomain)
    sign_in_as(user)
    visit "/admin/reports/#{report}" if report.present?
  end

  def item_rows_for_order(order)
    Dom::Report::ItemRow.all.select {|row| row.order_number.include?("#{order}") }
  end

  context 'as an admin' do
    let!(:user)  { create(:user, :admin) }

    context "viewing 'Total Sales' report" do
      let(:report) { 'total-sales' }

      scenario "date range defaults to last 30 days and can filter results" do
        skip 'Fails intermittently, revisit w/ rails 5 transactional rollbacks in specs'

        expect(item_rows_for_order("LO-01-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-2").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-3").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-4").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-2").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-3").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-4").count).to eq(1)
        expect(item_rows_for_order("LO-03-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-03-234-4567890-2").count).to eq(0)

        fill_in "q_order_placed_at_date_gteq", with: 6.weeks.ago.to_date
        click_button "Filter"

        expect(item_rows_for_order("LO-01-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-2").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-3").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-4").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-2").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-3").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-4").count).to eq(1)
        expect(item_rows_for_order("LO-03-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-03-234-4567890-2").count).to eq(1)

        fill_in "q_order_placed_at_date_lteq", with: order_date + 2.days
        click_button "Filter"

        expect(item_rows_for_order("LO-01-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-2").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-3").count).to eq(0)
        expect(item_rows_for_order("LO-01-234-4567890-4").count).to eq(0)
        expect(item_rows_for_order("LO-02-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-2").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-3").count).to eq(0)
        expect(item_rows_for_order("LO-02-234-4567890-4").count).to eq(0)
        expect(item_rows_for_order("LO-03-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-03-234-4567890-2").count).to eq(1)
      end

      scenario "shows a product code" do
        expect(page).to have_content("product-code-1")
      end

      scenario "displays the appropriate filters" do
        expect(page).to have_field("Search")
        expect(page).to have_field("Placed on or after")
        expect(page).to have_field("Placed on or before")
        expect(page).to have_selector(:id, 'filter-options-market')
      end

      scenario "searches by order number" do
        expect(Dom::Report::ItemRow.all.count).to eq(11)

        fill_in "Search", with: "LO-02"
        click_button "Search"

        expect(Dom::Report::ItemRow.all.count).to eq(5)
        expect(item_rows_for_order("LO-02-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-2").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-3").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-4").count).to eq(1)

        fill_in "Search", with: "LO-03"
        click_button "Search"

        expect(Dom::Report::ItemRow.all.count).to eq(1)
        expect(item_rows_for_order("LO-03-234-4567890-1").count).to eq(1)
      end

      scenario "searches by purchase order number" do
        expect(Dom::Report::ItemRow.all.count).to eq(11)

        fill_in "Search", with: "PURCHASE-0"
        click_button "Search"

        expect(Dom::Report::ItemRow.all.count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-0").count).to eq(1)

        fill_in "Search", with: "PURCHASE-1"
        click_button "Search"

        expect(Dom::Report::ItemRow.all.count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-1").count).to eq(1)
      end

      scenario "filters by market" do
        expect(Dom::Report::ItemRow.all.count).to eq(11)

        select_option_on_multiselect('#filter-options-market', market.name)
        click_button "Filter"

        expect(Dom::Report::ItemRow.all.count).to eq(5)
        expect(item_rows_for_order("LO-01-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-2").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-3").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-4").count).to eq(1)

        unselect_option_on_multiselect('#filter-options-market', market.name)

        select_option_on_multiselect('#filter-options-market', market2.name)
        click_button "Filter"

        expect(Dom::Report::ItemRow.all.count).to eq(5)
        expect(item_rows_for_order("LO-02-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-2").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-3").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-4").count).to eq(1)

        unselect_option_on_multiselect('#filter-options-market', market2.name)
      end

      it "shows the appropriate order items" do
        items = Dom::Report::ItemRow.all

        expect(items.count).to eq(11)

        # default sort order is placed_at descending
        expect(items[0].order_date).to eq(display_date(order_date + 4.days))
        expect(items[1].order_date).to eq(display_date(order_date + 4.days))
        expect(items[2].order_date).to eq(display_date(order_date + 3.days))
        expect(items[3].order_date).to eq(display_date(order_date + 3.days))
        expect(items[4].order_date).to eq(display_date(order_date + 2.days))
        expect(items[5].order_date).to eq(display_date(order_date + 2.days))
        expect(items[6].order_date).to eq(display_date(order_date + 1.day))
        expect(items[7].order_date).to eq(display_date(order_date + 1.day))
        expect(items[8].order_date).to eq(display_date(order_date))
        expect(items[9].order_date).to eq(display_date(order_date))
        expect(items[10].order_date).to eq(display_date(order_date - 1.day))

        expect(item_rows_for_order("LO-01-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-2").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-3").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-4").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-2").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-3").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-4").count).to eq(1)
        expect(item_rows_for_order("LO-03-234-4567890-1").count).to eq(1)
      end

      # FIXME: behavior was changed to a background job instead of rendered inline, fails without USE_UPLOAD_QUEUE = false
      xscenario "FIXME: can download a CSV of report" do
        items = Dom::Report::ItemRow.all
        html_headers = page.all(".report-table th").map(&:text)

        html_headers[html_headers.index("Qty.")] = "Quantity"

        expect(items.count).to eq(11)

        click_link "Export CSV"

        csv = CSV.parse(page.body, headers: true)

        expect(csv.count).to eq(items.count)

        # Ensure all columns in HTML are in CSV
        expect(html_headers - csv.headers).to be_empty
        # For all fields defined for the current report, ensure we have
        # corresponding values in our CSV file. Fields for a given report
        # are defined in ReportPresenter.
        field_headers = ReportPresenter.field_headers_for_report(report)
        items.each_with_index do |item, i|
          field_headers.each_pair do |field, display_name|
            if ["Actual Discount", "Actual Discounts"].include? display_name # We're hiding the discounts column in the html view
              next
            elsif display_name == "Product Code" # The product name and product code columns are merged in the html view
              next
            else
              expect(item.send(field)).to include(csv[i][display_name])
              if display_name == "Product"
                expect(item.send(field)).to include(csv[i]["Product Code"])
              elsif display_name == "Placed On"
                expect(item.send(field)).to include(csv[i]["Order Number"])
              end
            end
          end
        end
      end

      # FIXME: behavior was changed to a background job instead of rendered inline, fails without USE_UPLOAD_QUEUE = false
      xscenario "FIXME: can download a CSV of all records irrespective of pagniation" do
        category = create(:category)
        product = create(:product,
                         :sellable,
                         category: category,
                         organization: seller)
        order_items = create_list(:order_item, 20, product: product, seller_name: seller.name)
        order_items.each do |order_item|
          create(:order,
                 market_id: market.id,
                 delivery: delivery,
                 items: [order_item],
                 organization: buyer)
        end

        visit(current_path + "?per_page=25")

        # paginates to 25
        expect(Dom::Report::ItemRow.all.count).to eq(25)

        click_link "Export CSV"

        csv = CSV.parse(page.body, headers: true)

        expect(csv.count).to eq(31) # 11 + 20
      end

    end

    context "viewing 'Sales by Supplier' report" do
      let(:report) { 'sales-by-supplier' }

      scenario "displays the appropriate filters" do
        expect(page).to have_field("Search")
        expect(page).to have_field("Placed on or after")
        expect(page).to have_field("Placed on or before")
        expect(page).to have_selector(:id, 'filter-options-market')
        expect(page).to have_selector(:id, 'filter-options-supplier')
      end

      scenario "filters by supplier" do
        expect(Dom::Report::ItemRow.all.count).to eq(11)

        select_option_on_multiselect('#filter-options-supplier', seller.name)
        click_button "Filter"

        expect(Dom::Report::ItemRow.all.count).to eq(5)
        expect(item_rows_for_order("LO-01-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-2").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-3").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-4").count).to eq(1)

        unselect_option_on_multiselect('#filter-options-supplier', seller.name)

        select_option_on_multiselect('#filter-options-supplier', seller2.name)
        click_button "Filter"

        expect(Dom::Report::ItemRow.all.count).to eq(5)
        expect(item_rows_for_order("LO-02-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-2").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-3").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-4").count).to eq(1)

        unselect_option_on_multiselect('#filter-options-supplier', seller2.name)
      end
    end

    context "viewing 'Sales by Buyer' report" do
      let(:report) { 'sales-by-buyer' }

      scenario "displays the appropriate filters" do
        expect(page).to have_field("Search")
        expect(page).to have_field("Placed on or after")
        expect(page).to have_field("Placed on or before")
        expect(page).to have_selector(:id, 'filter-options-market')
      end

      scenario "filters by buyer" do
        expect(Dom::Report::ItemRow.all.count).to eq(11)

        select_option_on_multiselect('#filter-options-buyer', buyer.name)
        click_button "Filter"

        expect(Dom::Report::ItemRow.all.count).to eq(5)
        expect(item_rows_for_order("LO-01-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-2").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-3").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-4").count).to eq(1)

        unselect_option_on_multiselect('#filter-options-buyer', buyer.name)

        select_option_on_multiselect('#filter-options-buyer', buyer2.name)
        click_button "Filter"

        expect(Dom::Report::ItemRow.all.count).to eq(5)
        expect(item_rows_for_order("LO-02-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-2").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-3").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-4").count).to eq(1)

        unselect_option_on_multiselect('#filter-options-buyer', buyer2.name)
      end
    end

    context "viewing 'Sales by Product' report" do
      let(:report) { 'sales-by-product' }

      scenario "displays the appropriate filters" do
        expect(page).to have_field("Search")
        expect(page).to have_field("Placed on or after")
        expect(page).to have_field("Placed on or before")
        expect(page).to have_selector(:id, 'filter-options-market')
        expect(page).to have_selector(:id, 'filter-options-category')
        expect(page).to have_selector(:id, 'filter-options-product')
      end

      scenario "filters by category" do
        expect(Dom::Report::ItemRow.all.count).to eq(11)

        select_option_on_multiselect('#filter-options-category', 'Category-01-0')
        click_button "Filter"

        expect(Dom::Report::ItemRow.all.count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-0").count).to eq(1)

        unselect_option_on_multiselect('#filter-options-category', 'Category-01-0')

        select_option_on_multiselect('#filter-options-category', 'Category-01-1')
        click_button "Filter"

        expect(Dom::Report::ItemRow.all.count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-1").count).to eq(1)

        unselect_option_on_multiselect('#filter-options-category', 'Category-01-1')
      end

      scenario "filters by product" do
        expect(Dom::Report::ItemRow.all.count).to eq(11)

        select_option_on_multiselect('#filter-options-product', 'Product0')
        click_button "Filter"

        expect(Dom::Report::ItemRow.all.count).to eq(2)
        expect(item_rows_for_order("LO-01-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-0").count).to eq(1)

        unselect_option_on_multiselect('#filter-options-product', 'Product0')

        select_option_on_multiselect('#filter-options-product', 'Product1')
        click_button "Filter"

        expect(Dom::Report::ItemRow.all.count).to eq(2)
        expect(item_rows_for_order("LO-01-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-1").count).to eq(1)

        unselect_option_on_multiselect('#filter-options-product', 'Product1')
      end
    end

    context "viewing 'Sales by Payment Method' report" do
      let(:report) { 'sales-by-payment-method' }

      scenario "displays the appropriate filters" do
        expect(page).to have_field("Search")
        expect(page).to have_field("Placed on or after")
        expect(page).to have_field("Placed on or before")
        expect(page).to have_selector(:id, 'filter-options-market')
        expect(page).to have_selector(:id, 'filter-options-payment-method')
      end

      scenario "filters by payment method" do
        expect(Dom::Report::ItemRow.all.count).to eq(11)

        select_option_on_multiselect('#filter-options-payment-method', 'ACH')
        click_button "Filter"

        expect(Dom::Report::ItemRow.all.count).to eq(4)
        expect(item_rows_for_order("LO-01-234-4567890-3").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-3").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-4").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-4").count).to eq(1)

        unselect_option_on_multiselect('#filter-options-payment-method', 'ACH')

        select_option_on_multiselect('#filter-options-payment-method', 'Purchase Order')
        click_button "Filter"

        expect(Dom::Report::ItemRow.all.count).to eq(6)
        expect(item_rows_for_order("LO-01-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-2").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-2").count).to eq(1)

        unselect_option_on_multiselect('#filter-options-payment-method', 'Purchase Order')
      end
    end
  end

  context "as a market manager of a single market" do
    let!(:user) { create(:user, :market_manager, managed_markets: [market]) }

    context "viewing 'Total Sales' report" do
      let(:report) { 'total-sales' }

      scenario "does not display the market filter" do
        expect(page).to have_field("Search")
        expect(page).to have_field("Placed on or after")
        expect(page).to have_field("Placed on or before")
        expect(page).to_not have_selector(:id, 'filter-options-market')
      end

      scenario "displays a product code" do
        expect(page).to have_content("product-code-1")
      end

      it "shows the appropriate order items" do
        items = Dom::Report::ItemRow.all

        expect(items.count).to eq(5)

        # default sort order is placed_at descending
        expect(items[0].order_date).to eq(display_date(order_date + 4.days))
        expect(items[1].order_date).to eq(display_date(order_date + 3.days))
        expect(items[2].order_date).to eq(display_date(order_date + 2.days))
        expect(items[3].order_date).to eq(display_date(order_date + 1.days))
        expect(items[4].order_date).to eq(display_date(order_date))

        expect(item_rows_for_order("LO-01-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-2").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-3").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-4").count).to eq(1)
      end

      it "displays total sales" do
        totals = Dom::Admin::TotalSales.first

        expect(totals.gross_sales).to eq("$110.00")
        expect(totals.market_fees).to eq("$2.50")
        expect(totals.lo_fees).to eq("$0.00")
        expect(totals.processing_fees).to eq("$6.25")
        expect(totals.delivery_fees).to eq("$5.00")
        expect(totals.discount_seller).to eq("$0.00")
        expect(totals.discount_market).to eq("$0.00")
        expect(totals.net_sales).to eq("$101.25")
      end

      it "provides the admin link to Orders" do
        see_admin_order_link(order: Order.find_by(order_number: 'LO-01-234-4567890-0'))
      end

      it "provides the admin link to products" do
        skip 'Fails intermittently, revisit w/ rails 5 transactional rollbacks in specs'

        product_name = Dom::Report::ItemRow.first.product_name
        # Hack off ' product-code-X' from product_name
        product_name = product_name.split(" ").first
        product = Product.find_by(name: product_name)

        see_admin_product_link(product: product)
      end

      it "provides the Admin link to Sellers" do
        seller_name = Dom::Report::ItemRow.first.seller_name
        see_admin_seller_link seller: Organization.selling.find_by(name: seller_name)
      end

      context "who deletes an organization" do
        it "shows the appropriate order items" do
          delete_organization(buyer)
          delete_organization(seller)

          visit '/admin/reports/total-sales'

          items = Dom::Report::ItemRow.all

          expect(items.count).to eq(5)

          # default sort order is placed_at descending
          expect(items[0].order_date).to eq(display_date(order_date + 4.days))
          expect(items[1].order_date).to eq(display_date(order_date + 3.days))
          expect(items[2].order_date).to eq(display_date(order_date + 2.days))
          expect(items[3].order_date).to eq(display_date(order_date + 1.days))
          expect(items[4].order_date).to eq(display_date(order_date))

          expect(item_rows_for_order("LO-01-234-4567890-0").count).to eq(1)
          expect(item_rows_for_order("LO-01-234-4567890-1").count).to eq(1)
          expect(item_rows_for_order("LO-01-234-4567890-2").count).to eq(1)
          expect(item_rows_for_order("LO-01-234-4567890-3").count).to eq(1)
          expect(item_rows_for_order("LO-01-234-4567890-4").count).to eq(1)
        end
      end
    end
  end

  context "as a supplier" do
    let(:supplier_org) { seller2 }
    let!(:user)      { create(:user, :supplier, organizations: [supplier_org]) }
    let!(:subdomain) { market2.subdomain }

    context "viewing 'Total Sales' report" do
      let(:report) { 'total-sales' }

      scenario "displays a product code" do
        expect(page).to have_content("product-code-1")
      end

      it "shows the appropriate order items" do
        items = Dom::Report::ItemRow.all

        expect(items.count).to eq(5)

        # default sort order is placed_at descending
        expect(items[0].order_date).to eq(display_date(order_date + 4.days))
        expect(items[1].order_date).to eq(display_date(order_date + 3.days))
        expect(items[2].order_date).to eq(display_date(order_date + 2.days))
        expect(items[3].order_date).to eq(display_date(order_date + 1.days))
        expect(items[4].order_date).to eq(display_date(order_date))

        expect(item_rows_for_order("LO-02-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-2").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-3").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-4").count).to eq(1)
      end
    end

    context "with purchases" do
      let!(:order)     { create(:order, items: [create(:order_item, product: create(:product, :sellable, organization: seller2))], market: market2, organization: buyer2) }

      context "Sales by Product report" do
        let(:report) { 'sales-by-product' }

        scenario "displays the appropriate filters" do
          expect(page).to have_field("Search")
          expect(page).to have_field("Placed on or after")
          expect(page).to have_field("Placed on or before")
          expect(page).to have_selector(:id, 'filter-options-category')
          expect(page).to have_selector(:id, 'filter-options-product')
        end

        scenario "displays total sales" do
          totals = Dom::Admin::TotalSales.first

          expect(totals.gross_sales).to eq("$110.00")
          expect(totals.market_fees).to eq("$0.00")
          expect(totals.lo_fees).to eq("$0.00")
          expect(totals.processing_fees).to eq("$0.00")
          expect(totals).to_not have_content("Delivery Fee")
          expect(totals.discounts).to eq("$0.00")
          expect(totals.net_sales).to eq("$110.00")
        end

        it "provides the admin link to Orders" do
          order_number = Dom::Report::ItemRow.first.order_number
          see_admin_order_link order: Order.find_by(order_number:order_number)
        end

        it "provides the Admin link to Products" do
          product_name = Dom::Report::ItemRow.first.product_name
          # Hack off ' product-code-X' from product_name
          product_name = product_name.split(" ").first
          product = Product.find_by(name: product_name, organization: supplier_org)
          see_admin_product_link(product: product)
        end

        it "provides the Admin link to Sellers" do
          seller_name = Dom::Report::ItemRow.first.seller_name
          see_admin_seller_link seller: Organization.selling.find_by(name: seller_name)
        end
      end

      context "Total Purchases report" do
        let(:report) { 'total-sales' }

        scenario "displays the appropriate filters" do
          expect(page).to have_field("Search")
          expect(page).to have_field("Placed on or after")
          expect(page).to have_field("Placed on or before")
        end

        scenario "displays total sales" do
          totals = Dom::Admin::TotalSales.first

          expect(totals.gross_sales).to eq("$110.00")
          expect(totals.market_fees).to eq("$0.00")
          expect(totals.lo_fees).to eq("$0.00")
          expect(totals.processing_fees).to eq("$0.00")
          expect(totals.discounts).to eq("$0.00")
          expect(totals).to_not have_content("Delivery Fee")
          expect(totals.net_sales).to eq("$110.00")
        end

        it "provides the admin link to Orders" do
          order_number = Dom::Report::ItemRow.first.order_number
          see_admin_order_link order: Order.find_by(order_number:order_number)
        end

        it "provides the Admin link to Products" do
          product_name = Dom::Report::ItemRow.first.product_name
          # Hack off ' product-code-X' from product_name
          product_name = product_name.split(" ").first
          product = Product.find_by(name: product_name, organization: supplier_org)
          see_admin_product_link(product: product)
        end

        it "provides the Admin link to Sellers" do
          seller_name = Dom::Report::ItemRow.first.seller_name
          see_admin_seller_link seller: Organization.selling.find_by(name: seller_name)
        end
      end
    end
  end

  context "as a Buyer" do
    let!(:user) { create(:user, :buyer, organizations: [buyer]) }

    context "viewing 'Total Sales' report" do
      let(:report) { 'total-sales' }

      scenario "does not show a product code" do
        expect(page).to_not have_content("product-code-1")
      end
    end

    context "Purchases by Product report" do
      let(:report) { 'purchases-by-product' }

      scenario "displays the appropriate filters" do
        expect(page).to have_field("Search")
        expect(page).to have_field("Placed on or after")
        expect(page).to have_field("Placed on or before")
        expect(page).to have_selector(:id, 'filter-options-category')
        expect(page).to have_selector(:id, 'filter-options-product')
      end

      scenario "displays total sales" do
        totals = Dom::Admin::TotalSales.first
        expect(totals.discounted_total).to eq("$110.00")
        expect(page).to have_content("Total Purchase")
        expect(page).not_to have_content("Market Fee")
        expect(page).not_to have_content("Delivery Fee")
      end

      scenario "filters by category" do
        expect(Dom::Report::ItemRow.all.count).to eq(5)

        select_option_on_multiselect('#filter-options-category', 'Category-01-0')
        click_button "Filter"

        expect(Dom::Report::ItemRow.all.count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-0").count).to eq(1)
        unselect_option_on_multiselect('#filter-options-category', 'Category-01-0')

        select_option_on_multiselect('#filter-options-category', 'Category-01-1')
        click_button "Filter"

        expect(Dom::Report::ItemRow.all.count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-1").count).to eq(1)
        unselect_option_on_multiselect('#filter-options-category', 'Category-01-1')
      end

      # https://www.pivotaltracker.com/story/show/78823306
      scenario "provides the Buyer link to Orders" do
        see_buyer_order_link(order: Order.find_by(order_number: 'LO-01-234-4567890-1'))
      end

      scenario "provides the Buyer link to Products" do
        skip 'Fails intermittently, revisit w/ rails 5 transactional rollbacks in specs'

        product_name = Dom::Report::ItemRow.first.product_name
        see_buyer_product_link product: Product.find_by(name: product_name)
      end

      scenario "provides the Buyer link to Suppliers" do
        seller_name = Dom::Report::ItemRow.first.seller_name
        see_buyer_seller_link seller: Organization.selling.find_by(name: seller_name)
      end
    end

    context "Total Purchases report" do
      let(:report) { 'total-purchases' }

      scenario "displays the appropriate filters" do
        expect(page).to have_field("Search")
        expect(page).to have_field("Placed on or after")
        expect(page).to have_field("Placed on or before")
      end

      scenario "displays total sales" do
        totals = Dom::Admin::TotalSales.first
        expect(totals.discounted_total).to eq("$110.00")
        expect(page).to have_content("Total Purchase")
        expect(page).not_to have_content("Market Fee")
        expect(page).not_to have_content("Delivery Fee")
      end

      scenario "provides the Buyer link to Orders" do
        see_buyer_order_link(order: Order.find_by(order_number: 'LO-01-234-4567890-1'))
      end

      scenario "provides the Buyer link to Products" do
        skip 'Fails intermittently, revisit w/ rails 5 transactional rollbacks in specs'

        product_name = Dom::Report::ItemRow.first.product_name
        see_buyer_product_link product: Product.find_by(name: product_name)
      end

      scenario "provides the Buyer link to Sellers" do
        seller_name = Dom::Report::ItemRow.first.seller_name
        see_buyer_seller_link seller: Organization.selling.find_by(name: seller_name)
      end
    end
  end
end
