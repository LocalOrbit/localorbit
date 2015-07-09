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
      expect(logic.unit_price(product, order.market, order.organization, 1).sale_price).to eql(3)
      expect(logic.unit_price(product, order.market, order.organization, 5).sale_price).to eql(2)
      expect(logic.unit_price(product, order.market, order.organization, 8).sale_price).to eql(1)
    end
  end
end