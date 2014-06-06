require "spec_helper"

describe "Reports" do
  let!(:market)    { create(:market, name: "Foo Market", po_payment_term: 30, timezone: "Eastern Time (US & Canada)") }
  let!(:market2)   { create(:market, name: "Bar Market", po_payment_term: 30, timezone: "Eastern Time (US & Canada)") }
  let!(:market3)   { create(:market, name: "Baz Market", po_payment_term: 30, timezone: "Eastern Time (US & Canada)") }
  let!(:seller)    { create(:organization, name: "Foo Seller", markets: [market], can_sell: true) }
  let!(:seller2)   { create(:organization, name: "Bar Seller", markets: [market2], can_sell: true) }
  let!(:subdomain) { market.subdomain }

  before do
    delivery_schedule = create(:delivery_schedule, market: market)
    delivery = delivery_schedule.next_delivery
    delivery_schedule2 = create(:delivery_schedule, market: market2)
    delivery2 = delivery_schedule2.next_delivery

    buyer   = create(:organization, name: "Foo Buyer", markets: [market], can_sell: false)
    buyer2  = create(:organization, name: "Bar Buyer", markets: [market2], can_sell: false)
    buyer3  = create(:organization, name: "Baz Buyer", markets: [market3], can_sell: false)

    order_date = DateTime.parse("May 9, 2014, 11:00:00")

    5.times do |i|
      this_date = order_date + i.days
      Timecop.freeze(this_date) do
        product = create(:product, :sellable, name: "Product#{i}", organization: seller)
        order_item = create(:order_item,
                            product: product,
                            seller_name: "Seller-01-#{i}",
                            unit_price: 20.00 + i, quantity: 1)
        create(:order,
               market_id: market.id,
               delivery: delivery,
               items: [order_item],
               organization: buyer,
               payment_method: ["purchase order", "purchase order", "purchase order", "ach", "ach", "credit card"][i],
               payment_status: "paid",
               order_number: "LO-01-234-4567890-#{i}")

        product = create(:product, :sellable, name: "Product#{i}", organization: seller2)
        order_item = create(:order_item,
                            product: product,
                            seller_name: "Seller-01-#{i}",
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

    switch_to_subdomain(subdomain)
    sign_in_as(user)
    within("#reports-dropdown") do
      click_link "Reports"
    end

    expect(page).to have_content("Total Sales")
  end

  def item_rows_for_order(order)
    Dom::Admin::SoldItemRow.all.select { |row| row.order_number.include?("#{order}") }
  end

  context "Total Sales" do
    context "as an Admin" do
      let!(:user) { create(:user, :admin) }

      it "shows the appropriate Total Sales report" do
        items = Dom::Admin::SoldItemRow.all

        expect(items.count).to eq(11)

        # default sort order is placed_at descending
        expect(items[0].placed_at).to eq("05/13/2014")
        expect(items[1].placed_at).to eq("05/13/2014")
        expect(items[2].placed_at).to eq("05/12/2014")
        expect(items[3].placed_at).to eq("05/12/2014")
        expect(items[4].placed_at).to eq("05/11/2014")
        expect(items[5].placed_at).to eq("05/11/2014")
        expect(items[6].placed_at).to eq("05/10/2014")
        expect(items[7].placed_at).to eq("05/10/2014")
        expect(items[8].placed_at).to eq("05/09/2014")
        expect(items[9].placed_at).to eq("05/09/2014")
        expect(items[10].placed_at).to eq("05/08/2014")

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
    end

    context "as a Market Manager" do
      let!(:user) { create(:user, managed_markets: [market]) }

      it "shows the appropriate Total Sales report" do
        items = Dom::Admin::SoldItemRow.all

        expect(items.count).to eq(5)

        # default sort order is placed_at descending
        expect(items[0].placed_at).to eq("05/13/2014")
        expect(items[1].placed_at).to eq("05/12/2014")
        expect(items[2].placed_at).to eq("05/11/2014")
        expect(items[3].placed_at).to eq("05/10/2014")
        expect(items[4].placed_at).to eq("05/09/2014")

        expect(item_rows_for_order("LO-01-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-2").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-3").count).to eq(1)
        expect(item_rows_for_order("LO-01-234-4567890-4").count).to eq(1)
      end
    end

    context "as a Seller" do
      let!(:user)      { create(:user, organizations: [seller2]) }
      let!(:subdomain) { market2.subdomain }

      it "shows the appropriate Total Sales report" do
        items = Dom::Admin::SoldItemRow.all

        expect(items.count).to eq(5)

        # default sort order is placed_at descending
        expect(items[0].placed_at).to eq("05/13/2014")
        expect(items[1].placed_at).to eq("05/12/2014")
        expect(items[2].placed_at).to eq("05/11/2014")
        expect(items[3].placed_at).to eq("05/10/2014")
        expect(items[4].placed_at).to eq("05/09/2014")

        expect(item_rows_for_order("LO-02-234-4567890-0").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-1").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-2").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-3").count).to eq(1)
        expect(item_rows_for_order("LO-02-234-4567890-4").count).to eq(1)
      end
    end
  end
end
