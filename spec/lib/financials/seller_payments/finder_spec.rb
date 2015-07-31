require "spec_helper"

describe Financials::SellerPayments::Finder do
  subject(:finder) { described_class }

  let(:builder) { ::Financials::SellerPayments::Builder }

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


  describe ".payable_automate_orders" do
    context "in general" do
      let(:results) { finder.payable_automate_orders(as_of: now_time) }
      let(:expected_orders) { m1[:orders] + m2[:orders] }

      it "gets all the payable orders on the Automate plan" do
        expect(results).to contain_exactly(*expected_orders)
      end
    end

    context "for a specific seller" do
      let(:seller) { m1[:seller_organizations].first }
      let(:user) { seller.users.first }
      let(:expected_orders) { Order.for_seller(user) }

      let(:results) { finder.payable_automate_orders(as_of: now_time, seller_id: seller.id) }

      it "returns only the orders for the given seller" do
        expect(results).to contain_exactly(*expected_orders)
      end

      context "for a specific subset of Orders" do
        let(:expected_orders) { [Order.for_seller(user).last] }
        let(:results) { 
          finder.payable_automate_orders(
            as_of: now_time, 
            seller_id: seller.id, 
            order_id: expected_orders.map(&:id))
        }
        it "returns only the targeted orders" do
          expect(results).to contain_exactly(*expected_orders)
        end
      end
    end

  end

  describe ".find_payable_seller_orders" do
    let(:results) { finder.find_payable_seller_orders(as_of: now_time) }

    it "returns a list of SellerOrders based on payable orders" do
      expect(results).to have(8).items
      expect(results.map { |r| r.class }.uniq).to eq [SellerOrder]

      (m1[:orders] + m2[:orders]).each do |order|
        seller = order.items.first.seller
        seller_order = results.detect { |so| so.seller == seller }
        expect(seller_order).to be
        expect(seller_order.items.first.product.organization).to eq seller
      end
    end
  end


  describe ".find_seller_payment_sections" do
    context "(interaction test)" do
      let(:seller_id) { "the seller id" }
      let(:order_id) { "the order id" }
      let(:results) { finder.find_seller_payment_sections(as_of: now_time, seller_id: seller_id, order_id: order_id) }

      let(:seller1) { double "Seller 1", id: 1 }
      let(:seller2) { double "Seller 2", id: 2 }
      let(:so1) { double("SellerOrder 1", seller_id: 1, seller: seller1) }
      let(:so2) { double("SellerOrder 2", seller_id: 1, seller: seller1) }
      let(:so3) { double("SellerOrder 3", seller_id: 2, seller: seller2) }
      let(:fake_seller_orders) { [ so1, so2, so3 ] }
      

      it "finds payable seller orders, groups them by seller, generates SellerSections for each group" do
        expect(finder).to receive(:find_payable_seller_orders).
          with(as_of: now_time, seller_id: seller_id, order_id: order_id).
          and_return(fake_seller_orders)

        expect(builder).to receive(:build_seller_section).
          with(seller_organization: seller1, seller_orders: [ so1, so2 ]).
          and_return({seller_name: "SECTION 1"})

        expect(builder).to receive(:build_seller_section).
          with(seller_organization: seller2, seller_orders: [ so3 ]).
          and_return({seller_name: "SECTION 2"})

        SchemaValidation.with_validation(false) do
          expect(results).to contain_exactly({seller_name:"SECTION 1"}, {seller_name:"SECTION 2"})
        end
      end
    end

    context "(state-based test)" do
      let(:sellers) { (m1[:seller_organizations] + m2[:seller_organizations] + m3[:seller_organizations]).sort_by(&:name) }
      let(:results) { finder.find_seller_payment_sections(as_of: now_time) }

      it "creates an array of SellerSections for each Seller based on their payable orders" do
        expected_sections = sellers.map do |seller|
          orders = Order.for_seller(seller.users.first).sort_by(&:id)
          seller_orders = orders.map do |o| SellerOrder.new(o, seller) end
          builder.build_seller_section(
            seller_organization: seller, 
            seller_orders: seller_orders)
        end.sort_by do |s| s[:seller_name] end

        expect(results).to eq expected_sections
      end

      context "for a specific Seller and subset of Orders" do
        let(:seller) { m1[:seller_organizations].first }
        let(:user) { seller.users.first }
        let(:expected_orders) { [Order.for_seller(user).last] }

        let(:results) { 
          finder.find_seller_payment_sections(
            as_of: now_time, 
            seller_id: seller.id, 
            order_id: expected_orders.map(&:id))
        }

        it "returns only the specified orders for the given Seller" do
          expected_section = builder.build_seller_section(
            seller_organization: seller, 
            seller_orders: expected_orders.map do |o| SellerOrder.new(o, seller) end
          )

          expect(results).to eq [expected_section]
        end

      end
    end

  end
end
