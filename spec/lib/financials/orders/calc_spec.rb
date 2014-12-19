describe Financials::Orders::Calc do
  let(:calc) { described_class }

  let!(:m1) { Generate.market_with_orders(items: 3) }

  describe ".gross_item_total" do
    let(:order) { m1[:orders].first }

    it "sums the gross total of all items in an order" do
      expected_total = order.items.inject(0.to_d) { |sum,oi| sum + oi.gross_total }
      expect(calc.gross_item_total(items: order.items)).to eq expected_total
    end
  end

end
