describe Financials::MarketPayments::Finder do
  subject(:finder) { described_class }

  let(:builder) { ::Financials::MarketPayments::Builder }

  let(:order_time) { Time.zone.parse("May 20, 2014 2:00 PM") }
  let(:deliver_time) { Time.zone.parse("May 25, 2014 3:30 PM") }
  let(:now_time) { Time.zone.parse("May 30, 2014 1:15 AM") }

  let!(:m1) { Generate.market_with_orders(
                order_time: order_time, 
                deliver_time: deliver_time,
                paid_with: "credit card",
                delivered: "delivered",
                num_orders: 4,
                num_sellers: 2
  )}
  let!(:m2) { Generate.market_with_orders(
                order_time: order_time, 
                deliver_time: deliver_time,
                paid_with: "credit card",
                delivered: "delivered"
  )}
  # This market's orders will be too late to be considered payable:
  let!(:m3) { Generate.market_with_orders(
                order_time: now_time,
                deliver_time: now_time+1.day,
                paid_with: "credit card",
                delivered: "delivered"
  )}


  describe ".find_orders_with_payable_market_fees" do
    context "in general" do
      let(:results) { finder.find_orders_with_payable_market_fees(as_of: now_time) }
      let(:expected_orders) { m1[:orders] + m2[:orders] }

      it "gets all the payable orders on the Automate plan" do
        expect(results).to contain_exactly(*expected_orders)
      end
    end

    context "for a specific market" do
      let(:market) { m2[:market] }
      let(:expected_orders) { m2[:orders] }

      let(:results) { 
        finder.find_orders_with_payable_market_fees(
          as_of: now_time, 
          market_id: market.id) 
      }

      it "returns only the orders for the given Market" do
        expect(results).to contain_exactly(*expected_orders)
        expect(expected_orders.length).to be > 1
      end

      context "for a specific subset of Orders" do
        let(:expected_orders) { [m2[:orders].last] }
        let(:results) { 
          finder.find_orders_with_payable_market_fees(
            as_of: now_time, 
            market_id: market.id, 
            order_id: expected_orders.map(&:id))
        }
        it "returns only the targeted orders" do
          expect(results).to contain_exactly(*expected_orders)
        end
      end
    end

  end

  describe ".find_market_payment_sections" do
    context "(interaction test)" do
      let(:market_id) { "the market id" }
      let(:order_id) { "the order id" }

      let(:market1) { double "Market 1", id: 1 }
      let(:market2) { double "Market 2", id: 2 }
      let(:o1) { double("Order 1", market_id: 1, market: market1) }
      let(:o2) { double("Order 2", market_id: 1, market: market1) }
      let(:o3) { double("Order 3", market_id: 2, market: market2) }
      let(:fake_orders) { [ o1, o2, o3] }

      let(:market_section1) { {market_name:"SECTION 1"} }
      let(:market_section2) { {market_name:"SECTION 2"} }
      
      let(:results) { finder.find_market_payment_sections(as_of: now_time, market_id: market_id, order_id: order_id) }

      it "finds payable orders, groups them by market, generates MarketSections for each group" do
        expect(finder).to receive(:find_orders_with_payable_market_fees).
          with(as_of: now_time, market_id: market_id, order_id: order_id).
          and_return(fake_orders)
        
        expect(builder).to receive(:build_market_section).
          with(market: market1, orders: [ o1, o2 ]).
          and_return(market_section1)
       
        expect(builder).to receive(:build_market_section).
          with(market: market2, orders: [ o3 ]).
          and_return(market_section2)
        
        SchemaValidation.with_validation(false) do
          expect(results).to eq [market_section1, market_section2] 
        end
      end
    end

    context "(state-based test)" do
      let(:markets) { [m1[:market], m2[:market]] }
      let(:results) { finder.find_market_payment_sections(as_of: now_time) }

      it "creates an array of MarketSections for each Market based on their payable orders" do
        expected_sections = markets.map do |market|
          orders = Order.where(market:market).order(:order_number)
          builder.build_market_section(
            market: market, 
            orders: orders)
        end.sort_by do |s| s[:market_name] end
        
        # Check the full result:
        expect(results).to eq expected_sections

        # A litle sanity checking on our expectations:
        results.each do |section|
          expect(section[:order_rows]).not_to be_empty, "Sanity check failed: Section for #{section[:market_name]} has no OrderRows"
          expect(section[:payable_accounts_for_select]).not_to be_empty, "Sanity check failed: Section for #{section[:market_name]} has no payable bank accounts"
        end
      end

      context "for a specific Market and subset of Orders" do
        let(:markets) { [m1[:market], m2[:market]] }
        let(:market) { m1[:market] }
        # Grab just the first two:
        let(:expected_orders) { 
          Order.
            where(market:market).
            order(:order_number).
            to_a[0..1]
        }

        let(:results) { 
          finder.find_market_payment_sections(
            as_of: now_time,
            market_id: market.id,
            order_id: expected_orders.map(&:id))
        }
        # let(:seller) { m1[:seller_organizations].first }
        # let(:user) { seller.users.first }
        # let(:expected_orders) { [Order.for_seller(user).last] }
        #
        # let(:results) { 
        #   finder.find_seller_payment_sections(
        #     as_of: now_time, 
        #     seller_id: seller.id, 
        #     order_id: expected_orders.map(&:id))
        # }

        it "returns only the specified orders for the given Seller" do
          expected_section = builder.build_market_section(
              market: market, 
              orders: expected_orders)
          
          expect(results).to eq [expected_section]
        end
      end

    end
  end
end
