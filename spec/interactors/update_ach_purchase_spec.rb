require 'spec_helper'

describe UpdateAchPurchase do
  let!(:market)     { create(:market) }
  let!(:order_item) { create(:order_item, unit_price: 15.00, quantity: 2) }
  let!(:order)      { create(:order, market: market, items: [order_item], payment_method: "ach") }

  context "refund difference" do
    let!(:payment) { create(:payment, :checking, orders: [order], amount: 45.00, balanced_uri: '/balanced-debit-1', status: 'paid') }

    it "against one payment" do
      existing_debit = double("balanced debit", amount: 4500)
      expect(Balanced::Debit).to receive(:find).and_return(existing_debit)
      expect(existing_debit).to receive(:refund).with({ amount: 1500 })

      expect(order.reload.payments.count).to eql(1)

      UpdateAchPurchase.perform(order: order)

      expect(order.reload.payments.count).to eql(2)
      expect(Payment.first.amount.to_f).to eql(45.00)
      expect(Payment.last.amount.to_f).to eql(-15.00)
    end

    it "against multiple payment" do
      create(:payment, :credit_card, orders: [order], amount: 45.00, balanced_uri: '/balanced-debit-2', status: 'failed')
      create(:payment, :credit_card, orders: [order], amount: 45.00, balanced_uri: '/balanced-debit-3', status: 'paid')

      debit1 = double("balanced debit 1", amount: 4500)
      debit3 = double("balanced debit 3", amount: 4500)
      expect(Balanced::Debit).to receive(:find).with('/balanced-debit-1').and_return(debit1)
      expect(Balanced::Debit).to_not receive(:find).with('/balanced-debit-2')
      expect(Balanced::Debit).to receive(:find).with('/balanced-debit-3').and_return(debit3)
      expect(debit1).to receive(:refund).with({ amount: 4500 })
      expect(debit3).to receive(:refund).with({ amount: 1500 })

      expect(order.reload.payments.count).to eql(3)

      UpdateAchPurchase.perform(order: order)

      expect(order.reload.payments.count).to eql(4)
      expect(Payment.first.amount.to_f).to eql(45.00)
      expect(Payment.last.amount.to_f).to eql(-60.00)
    end

    it "records a failed refund when balanced fails" do
      existing_debit = double("balanced debit", amount: 4500)
      expect(Balanced::Debit).to receive(:find).and_return(existing_debit)
      expect(existing_debit).to receive(:refund).and_throw(Exception)

      expect(order.reload.payments.count).to eql(1)

      UpdateAchPurchase.perform(order: order)

      expect(order.reload.payments.count).to eql(2)
      expect(Payment.first.amount.to_f).to eql(45.00)
      expect(Payment.last.amount.to_f).to eql(-15.00)
      expect(Payment.last.status).to eql("failed")
    end
  end

  context "charge difference" do
    let!(:payment) { create(:payment, :credit_card, orders: [order], amount: 15.00, status: 'paid') }

    it "charges the difference when the order amount goes up" do
      existing_debit = double("balanced debit", account: OpenStruct.new(uri: '/balanced-account-uri'), source: OpenStruct.new(uri: '/balanced-source-uri'))
      balanced_customer = double("balanced_customer")
      expect(Balanced::Debit).to receive(:find).and_return(existing_debit)
      expect(Balanced::Customer).to receive(:find).with('/balanced-account-uri').and_return(balanced_customer)
      expect(balanced_customer).to receive(:debit).with({amount: 1500, source_uri: '/balanced-source-uri', description: "#{market.name} purchase"})

      expect(order.reload.payments.count).to eql(1)

      UpdateAchPurchase.perform(order: order)

      expect(order.reload.payments.count).to eql(2)
      expect(Payment.first.amount.to_f).to eql(15.00)
      expect(Payment.last.amount.to_f).to eql(15.00)
    end

    it "records a failed charge when balanced fails" do
      existing_debit = double("balanced debit", account: OpenStruct.new(uri: '/balanced-account-uri'), source: OpenStruct.new(uri: '/balanced-source-uri'))
      balanced_customer = double("balanced_customer")
      expect(Balanced::Debit).to receive(:find).and_return(existing_debit)
      expect(Balanced::Customer).to receive(:find).with('/balanced-account-uri').and_return(balanced_customer)
      expect(balanced_customer).to receive(:debit).and_throw(Exception)

      expect(order.reload.payments.count).to eql(1)

      UpdateAchPurchase.perform(order: order)

      expect(order.reload.payments.count).to eql(2)
      expect(Payment.last.amount.to_f).to eql(15.00)
      expect(Payment.last.status).to eql("failed")
    end
  end
end
