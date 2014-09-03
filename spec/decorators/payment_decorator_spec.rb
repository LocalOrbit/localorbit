require "spec_helper"

describe PaymentDecorator do
  let(:buyer)  { create(:organization, :buyer, markets: [market]) }
  let(:market) { create(:market) }
  let(:order)  { create(:order, organization: buyer, market: market) }

  let(:refund) {
    create(:payment,
           payment_type: "order refund",
           payment_method: "ach",
           payer: buyer,
           payee: nil,
           orders: [order],
           amount: -23.45).decorate
  }

  let(:payment) {
    create(:payment,
           payment_type: "order",
           payment_method: "ach",
           payer: buyer,
           payee: market,
           orders: [order],
           amount: 55.32).decorate
  }

  describe "#display_amount" do
    it "returns the inverse amount when the payment is a refund" do
      expect(refund.display_amount).to eql("$23.45")
    end

    it "returns the amount when the payment is not a refund" do
      expect(payment.display_amount).to eql("$55.32")
    end
  end

  describe "#to" do
    it "returns the payee when the payment is not a refund" do
      expect(payment.to).to eql(market.name)
    end

    it "returns the payer when the payment is a refund" do
      expect(refund.to).to eql(buyer.name)
    end
  end

  describe "#from" do
    it "returns the payer when the payment is not a refund" do
      expect(payment.from).to eql(buyer.name)
    end

    it "returns the payee when the payment is a refund" do
      expect(refund.from).to eql("Local Orbit")
    end
  end
end
