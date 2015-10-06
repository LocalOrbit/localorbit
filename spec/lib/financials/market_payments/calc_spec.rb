require 'spec_helper'

describe Financials::MarketPayments::Calc do
  let(:calc) { described_class }

  let(:order_time) { Time.zone.parse("May 20, 2014 2:00 PM") }
  let(:deliver_time) { Time.zone.parse("May 25, 2014 3:30 PM") }
  let(:now_time) { Time.zone.parse("May 30, 2014 1:15 AM") }

  let!(:m1) { Generate.market_with_orders(
                order_time: order_time, 
                deliver_time: deliver_time,
                items: 3,
                paid_with: "credit card",
                delivered: "delivered",
                num_orders: 1,
                delivery_fee_percent: 12.to_d
  )}

  let(:order) { m1[:orders].first }

  describe ".market_fee" do
    it "sums market_seller_fee across all items" do
      expect(calc.market_fee(order)).to eq "0.3".to_d
    end
  end

  describe ".market_delivery_fee" do
    it "returns the market's share of the delivery fees on the order" do
      expect(calc.market_delivery_fee(order)).to eq "1.813".to_d
    end
  end

  describe ".fee_owed_to_market" do
    it "adds the delivery and market fees together as a convenience" do
      expect(calc.fee_owed_to_market(order)).to eq "2.113".to_d
    end
  end
end
