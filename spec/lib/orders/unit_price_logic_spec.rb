require 'spec_helper'

describe Orders::UnitPriceLogic do
  subject(:logic) {described_class}
  let(:product) do
    create(:product, lots: [
      create(:lot, quantity: 3),
      create(:lot, quantity: 5)
    ],
    prices: [
      create(:price, min_quantity: 1, sale_price: 3),
      create(:price, min_quantity: 5, sale_price: 2),
      create(:price, min_quantity: 8, sale_price: 1)
    ])
  end
  let(:order) { build(:order, market: create(:market)) }

  describe "#unit_price" do
    it 'returns the appropriate price for a given quantity' do
      expect(logic.unit_price(product, order.market, order.organization, DateTime.now, 1).sale_price).to eql(3)
      expect(logic.unit_price(product, order.market, order.organization, DateTime.now, 5).sale_price).to eql(2)
      expect(logic.unit_price(product, order.market, order.organization, DateTime.now, 8).sale_price).to eql(1)
    end

    it "uses the prices that were valid at a given time, not the current pricing" do
      expect(logic.unit_price(product, order.market, order.organization, DateTime.now, 1).sale_price).to eql(3)
      order_time = DateTime.now
      Timecop.travel(order_time + 2.days) do
        Price.soft_delete(product.prices.first)
        Price.create!(min_quantity: 1, sale_price: 5, product: product)
        expect(logic.unit_price(product, order.market, order.organization, order_time, 1).sale_price).to eql(3)
        expect(logic.unit_price(product, order.market, order.organization, order_time, 5).sale_price).to eql(2)
        expect(logic.unit_price(product, order.market, order.organization, order_time, 8).sale_price).to eql(1)
      end
    end
  end
end