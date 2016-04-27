require "spec_helper"

describe Price do
  describe "validations" do
    it "allows multiple products to have the same price" do
      prod1 = create(:product)
      prod2 = create(:product)
      prod1.prices.create!(min_quantity: 1, sale_price: 2)

      price = prod2.prices.build(min_quantity: 1, sale_price: 2)
      expect(price).to have(0).errors_on(:min_quantity)
    end

    describe "price" do
      it "is required" do
        price = Price.new
        expect(price).to have(1).error_on(:sale_price)
      end

      it "is less than a million" do
        price = Price.new(sale_price: 1_000_000)
        expect(price).to have(1).error_on(:sale_price)
      end
    end

    describe "min quantity" do
      it "is required" do
        price = Price.new(min_quantity: nil)
        expect(price).to have(1).error_on(:min_quantity)
      end

      it "is less than a million" do
        price = Price.new(min_quantity: 1_000_000)
        expect(price).to have(1).error_on(:min_quantity)
      end
    end
  end

  describe "#net_price" do
    let(:market)  { create(:market, credit_card_seller_fee:0,credit_card_market_fee:1) }
    let(:org)     { create(:organization, markets: [market]) }
    let(:product) { create(:product, organization: org) }

    subject { build(:price, product: product, sale_price: nil, product_fee_pct: 0) }

    it "returns the adjusted sale_price for fees" do
      expect(subject.net_price).to eq(0)

      subject.sale_price = 1.99

      expect(subject.net_price).to eq(1.93) # 3% fees from market.LO fees + market.market_seller_fee

      subject.sale_price = 3.99

      expect(subject.net_price).to eq(3.87) # 3% fees as above
    end
  end

  describe "view_sorted" do
    let(:product) { create(:product) }

    it "has all buyers before a buyer specific price" do
      p2 = product.prices.create(min_quantity: 5, sale_price: 2)
      p3 = product.prices.create(organization: create(:organization), sale_price: 3)
      p1 = product.prices.create(sale_price: 2)

      expect(product.prices.view_sorted).to eq([p1, p2, p3])
    end

    it "has buyer specific pricing ordered by buyer name" do
      org1 = create(:organization, name: "Organic Farms")
      org2 = create(:organization, name: "Better Farms")

      p2 = product.prices.create(organization: org2, sale_price: 2)
      p3 = product.prices.create(organization: org1, sale_price: 2)
      p1 = product.prices.create(sale_price: 2)

      expect(product.prices.view_sorted).to eq([p1, p2, p3])
    end
  end
end
