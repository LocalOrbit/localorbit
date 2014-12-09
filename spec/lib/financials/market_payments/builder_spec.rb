describe Financials::MarketPayments::Builder do
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
                num_orders: 3
  )}


  describe ".build_order_totals" do
    let!(:order) { m1[:orders].first }

    before do
      order.update_columns(delivery_fees: 8) # sneak this past the re-calcs
    end

    it "sums the seller-related sales and fees into a Totals structure" do
      t = builder.build_order_totals(order)
      expect_valid_schema Financials::MarketPayments::Schema::Totals, t
      expect(t).to eq({
        order_total: "14.2".to_d, # 15.4 - 1.2 discount
        market_fee:   "0.3".to_d,
        delivery_fee:"7.84".to_d,
        owed:        "8.14".to_d,
      })
    end

  end

  describe ".build_order_row" do
    let(:order) { m1[:orders][1] }
    let(:order_totals) { builder.build_order_totals(order) }
  
    it "creates a valid OrderRow hash from an Order" do
      order_row = builder.build_order_row(order)
      expect_valid_schema Financials::MarketPayments::Schema::OrderRow, order_row
      expect(order_row).to eq({
        order_id: order.id,
        order_number: order.order_number,
        order_totals: order_totals
      })
    end
  end

  describe ".build_market_section" do
    # contrived, since we get to pass whatever we want:
    let(:orders) { [ m1[:orders].first, m1[:orders].last ] } 
    let(:market) { m1[:market] }

    let(:expected_order_rows) { 
      orders.
        sort_by(&:order_number).
        map do |o| 
          builder.build_order_row(o) 
        end
    }

    let(:expected_bank_account_options) { 
      Financials::BankAccounts::Builder.options_for_select(
        bank_accounts: Financials::BankAccounts::Finder.creditable_bank_accounts(
          bank_accounts: market.bank_accounts))
    }

    let(:expected_market_totals) { 
      DataCalc.sums_of_keys(expected_order_rows.map { |r| r[:order_totals] })
    }

    it "constructs a MarketSection" do
      section = builder.build_market_section(
        market: market,
        orders: orders
      )

      expect_valid_schema Financials::MarketPayments::Schema::MarketSection, section

      expect(section).to eq({
        market_id: market.id,
        market_name: market.name,
        payable_accounts_for_select: expected_bank_account_options,
        order_rows: expected_order_rows,
        market_totals: expected_market_totals,

      })
    end
  end

end
