describe Financials::SellerPayments::Builder do
  let(:builder) { described_class }

  let(:order_time) { Time.zone.parse("May 20, 2014 2:00 PM") }
  let(:deliver_time) { Time.zone.parse("May 25, 2014 3:30 PM") }
  let(:now_time) { Time.zone.parse("May 30, 2014 1:15 AM") }

  let!(:m1) { Generate.market_with_orders(
                order_time: order_time, 
                deliver_time: deliver_time,
                items: 3,
                paid_with: "credit card",
                delivered: "delivered",
  )}


  describe ".build_order_totals" do
    let(:order_items) { m1[:orders].first.items }
    it "sums the seller-related sales and fees into a Totals structure" do
      t = builder.build_order_totals(order_items)
      expect(t).to eq({
        gross_sales: "15.4".to_d,
        net_sales: "12.4".to_d,
        market_fees: "0.3".to_d,
        transaction_fees: "0.6".to_d,
        payment_processing_fees: "0.9".to_d,
        discounts: "1.2".to_d,
      })
    end

    it "provides a zero-Total for no items" do
      t = builder.build_order_totals([])
      expect(t).to eq({
        gross_sales: "0".to_d,
        net_sales: "0".to_d,
        market_fees: "0".to_d,
        transaction_fees: "0".to_d,
        payment_processing_fees: "0".to_d,
        discounts: "0".to_d,
      })
    end
  end

  describe ".build_order_row" do
    let(:order) { m1[:orders][1] }

    let(:seller1) { order.items.first.product.organization }
    let(:seller_order1) { SellerOrder.new(order, seller1) }

    let(:seller2) { order.items[1].product.organization }
    let(:seller_order2) { SellerOrder.new(order, seller2) }

    it "creates a valid OrderRow hash from a SellerOrder" do
      order_row = builder.build_order_row(seller_order1)
      expect(order_row).to eq({
        order_id: seller_order1.id,
        order_number: seller_order1.order_number,
        order_totals: builder.build_order_totals(seller_order1.items),
        delivery_status: "Delivered",
        buyer_payment_status: "Paid",
        seller_payment_status: "Unpaid",
        payment_method: "Credit Card"
      })
    end

    it "creates OrderRow with properly aggregated delivery status" do
      seller_order1.items.last.update delivery_status: "pending" # the other will be 'delivered'
      order_row = builder.build_order_row(seller_order1)
      expect(order_row[:delivery_status]).to eq 'Partially Delivered'
    end

    it "creates a valid OrderRow hash from another SellerOrder" do
      order_row = builder.build_order_row(seller_order2)
      expect(order_row).to eq({
        order_id: seller_order2.id,
        order_number: seller_order2.order_number,
        order_totals: builder.build_order_totals(seller_order2.items),
        delivery_status: "Delivered",
        buyer_payment_status: "Paid",
        seller_payment_status: "Unpaid",
        payment_method: "Credit Card"
      })
    end
  end

  describe ".build_seller_section" do
    let(:seller) { m1[:seller_organizations].first }
    let(:seller_orders) { Order.for_seller(seller.users.first) }

    it "constructs a SellerSection" do
      section = builder.build_seller_section(
        seller_organization: seller,
        seller_orders: seller_orders
      )
      expected_order_rows = seller_orders.map { |so| builder.build_order_row(so) }
      # expected_seller_totals = builder.crunch_totals(expected_order_rows.map { |r| r[:order_totals] })
      expected_seller_totals = DataCalc.sums_of_keys(expected_order_rows.map { |r| r[:order_totals] })
      expected_accounts = seller.
        bank_accounts.
        verified.
        creditable_bank_accounts.
        sort_by(&:display_name).
        map { |ba| [ ba.display_name, ba.id ] }

      expect(section).to eq({
        seller_id: seller.id,
        seller_name: seller.name,
        payable_accounts_for_select: expected_accounts,
        order_rows: expected_order_rows,
        seller_totals: expected_seller_totals
      })

    end
  end

end
