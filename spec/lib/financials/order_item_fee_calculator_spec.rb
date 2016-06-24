require 'spec_helper'

describe Financials::OrderItemFeeCalculator do
  subject { described_class }

  let(:market) { double("a market", 
                        market_seller_fee: "16.667".to_d,
                        local_orbit_seller_fee: "2".to_d,
                        local_orbit_market_fee: "5".to_d) }

  let!(:order) { double("and order", market_seller_fee_pct: "16.667".to_d) }

  let!(:category) { double("a category",
                            level_fee: 0
                            )}

  let!(:product) { double("a product",
                            category: category
                            )}

  let(:order_item) { double("an order item",
                            order: order,
                            gross_total: "65.37".to_d,
                            discount_seller: "1.96".to_d, 
                            discount_market: "1.63".to_d,
                            product_fee_pct: "0.0".to_d,
                            market_seller_fee: "4.44".to_d,
                            quantity: "4".to_d,
                            unit_price: "6.66".to_d,
                            product: product,
                            category_fee_pct: 0
                            )}


  let(:order_item_product_fee) { double("an order item",
                            gross_total: "65.37".to_d,
                            discount_seller: "1.96".to_d,
                            discount_market: "1.63".to_d,
                            product_fee_pct: "20.0".to_d,
                            product: product,
                            category_fee_pct: 0
                            )}

  describe ".market_fee_paid_by_seller" do
    it "discounts an item's gross_total by the seller-paid discount amount and multiplies by market's seller fee rate" do
      fee = subject.market_fee_paid_by_seller(market: market, order_item: order_item)
      expect(fee).to eq "10.57".to_d
    end
  end

  describe ".product_market_fee_paid_by_seller" do
    it "discounts an item's gross_total by the seller-paid discount amount and multiplies by product's seller fee rate" do
      fee = subject.market_fee_paid_by_seller(market: market, order_item: order_item_product_fee)
      expect(fee).to eq "12.68".to_d
    end
  end

  describe ".local_orbit_fee_paid_by_seller" do
    # TODO: IS THIS FINANCIALLY CORRECT?  Really discount the gross total by both seller and market share of the discount? This was how it was originally in StoreOrderFees.  crosby 2015-06-02
    it "discounts an item's gross_total by the both discount amounts and multiplies by the rate LO charges the seller" do
      fee = subject.local_orbit_fee_paid_by_seller(market: market, order_item: order_item)
      expect(fee).to eq "1.24".to_d
    end
  end

  describe ".local_orbit_fee_paid_by_market" do
    # TODO: IS THIS FINANCIALLY CORRECT?  Really discount the gross total by both seller and market share of the discount? This was how it was originally in StoreOrderFees.  crosby 2015-06-02
    it "discounts an item's gross_total by the both discount amounts and multiplies by the rate LO charges the market" do
      fee = subject.local_orbit_fee_paid_by_market(market: market, order_item: order_item)
      expect(fee).to eq "3.09".to_d
    end
  end
end
