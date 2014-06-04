require 'spec_helper'

describe UpdateBalancedPurchase do
  let!(:market)     { create(:market) }
  let!(:delivery_schedule) { create(:delivery_schedule, fee: 0.0, fee_type: 'fixed') }
  let!(:delivery)    { delivery_schedule.next_delivery }

  let!(:order_item) { create(:order_item, unit_price: 15.00, quantity: 2) }

  context "credit card" do
    let!(:order)      { create(:order, delivery: delivery, market: market, items: [order_item], payment_method: "credit card") }

    context "without any items" do
      let!(:payment) { create(:payment, :credit_card, orders: [order], amount: 45.00, balanced_uri: '/balanced-debit-1') }

      before do
        order.items.delete_all
        order.save!
      end

      it 'refunds the entire amount' do
        existing_debit = double("balanced debit", amount: 4500, source: OpenStruct.new(_type: 'card'))
        expect(Balanced::Debit).to receive(:find).and_return(existing_debit)
        expect(existing_debit).to receive(:refund).with({ amount: 4500 })

        expect(order.reload.payments.count).to eql(1)

        UpdateBalancedPurchase.perform(order: order)

        expect(order.reload.payments.count).to eql(2)
        expect(order.total_cost.to_f).to eql(0.0)
        expect(Payment.first.amount.to_f).to eql(45.00)
        expect(Payment.first.refunded_amount.to_f).to eql(45.00)
        expect(Payment.last.amount.to_f).to eql(-45.00)
      end
    end

    context "refund difference" do
      let!(:payment) { create(:payment, :credit_card, orders: [order], amount: 45.00, balanced_uri: '/balanced-debit-1') }

      it "against one payment" do
        existing_debit = double("balanced debit", amount: 4500, source: OpenStruct.new(_type: 'card'))
        expect(Balanced::Debit).to receive(:find).and_return(existing_debit)
        expect(existing_debit).to receive(:refund).with({ amount: 1500 })

        expect(order.reload.payments.count).to eql(1)

        UpdateBalancedPurchase.perform(order: order)

        expect(order.reload.payments.count).to eql(2)
        expect(Payment.first.amount.to_f).to eql(45.00)
        expect(Payment.first.refunded_amount.to_f).to eql(15.00)
        expect(Payment.last.amount.to_f).to eql(-15.00)
      end

      it "against multiple payment" do
        create(:payment, :checking, orders: [order], amount: 45.00, balanced_uri: '/balanced-debit-2', status: 'failed')
        create(:payment, :checking, orders: [order], amount: 20.00, balanced_uri: '/balanced-debit-3')
        create(:payment, :checking, orders: [order], amount: 25.00, balanced_uri: '/balanced-debit-4')

        debit1 = double("balanced debit 1", amount: 4500, source: OpenStruct.new(_type: 'card'))
        debit3 = double("balanced debit 3", amount: 2000, source: OpenStruct.new(_type: 'card'))
        expect(Balanced::Debit).to receive(:find).with('/balanced-debit-1').and_return(debit1)
        expect(Balanced::Debit).to receive(:find).with('/balanced-debit-3').and_return(debit3)
        expect(Balanced::Debit).to_not receive(:find).with('/balanced-debit-4')
        expect(debit1).to receive(:refund).with({ amount: 4500 })
        expect(debit3).to receive(:refund).with({ amount: 1500 })

        expect(order.reload.payments.count).to eql(4)

        UpdateBalancedPurchase.perform(order: order)

        expect(order.reload.payments.count).to eql(6)
        expect(Payment.first.amount.to_f).to eql(45.00)
        expect(Payment.first.refunded_amount.to_f).to eql(45.00)
        expect(Payment.last.amount.to_f).to eql(-15.00)
      end

      it "records a failed refund when balanced fails" do
        existing_debit = double("balanced debit", amount: 4500, source: OpenStruct.new(_type: 'card'))
        expect(Balanced::Debit).to receive(:find).and_return(existing_debit)
        expect(existing_debit).to receive(:refund).and_throw(Exception)

        expect(order.reload.payments.count).to eql(1)

        UpdateBalancedPurchase.perform(order: order)

        expect(order.reload.payments.count).to eql(2)
        expect(Payment.first.amount.to_f).to eql(45.00)
        expect(Payment.last.amount.to_f).to eql(-15.00)
        expect(Payment.last.status).to eql("failed")
      end
    end

    context "charge difference" do
      let!(:payment) { create(:payment, :credit_card, orders: [order], amount: 15.00) }

      it "charges the difference when the order amount goes up" do
        existing_debit = double("balanced debit", account: OpenStruct.new(uri: '/balanced-account-uri'), source: OpenStruct.new(_type: 'card', uri: '/balanced-source-uri'))
        balanced_customer = double("balanced_customer")
        expect(Balanced::Debit).to receive(:find).and_return(existing_debit)
        expect(Balanced::Customer).to receive(:find).with('/balanced-account-uri').and_return(balanced_customer)
        expect(balanced_customer).to receive(:debit).with({amount: 1500, source_uri: '/balanced-source-uri', description: "#{market.name} purchase"})

        expect(order.reload.payments.count).to eql(1)

        UpdateBalancedPurchase.perform(order: order)

        expect(order.reload.payments.count).to eql(2)
        expect(Payment.first.amount.to_f).to eql(15.00)
        expect(Payment.last.amount.to_f).to eql(15.00)
      end

      it "records a failed charge when balanced fails" do
        existing_debit = double("balanced debit", account: OpenStruct.new(uri: '/balanced-account-uri'), source: OpenStruct.new(_type: 'card', uri: '/balanced-source-uri'))
        balanced_customer = double("balanced_customer")
        expect(Balanced::Debit).to receive(:find).and_return(existing_debit)
        expect(Balanced::Customer).to receive(:find).with('/balanced-account-uri').and_return(balanced_customer)
        expect(balanced_customer).to receive(:debit).and_throw(Exception)

        expect(order.reload.payments.count).to eql(1)

        UpdateBalancedPurchase.perform(order: order)

        expect(order.reload.payments.count).to eql(2)
        expect(Payment.last.amount.to_f).to eql(15.00)
        expect(Payment.last.status).to eql("failed")
      end
    end
  end

  context "ach" do
    let!(:order)      { create(:order, delivery: delivery, market: market, items: [order_item], payment_method: "ach") }

    context "refund difference" do
      let!(:payment) { create(:payment, :checking, orders: [order], amount: 45.00, balanced_uri: '/balanced-debit-1') }

      it "against one payment" do
        existing_debit = double("balanced debit", amount: 4500, source: OpenStruct.new(_type: 'ach'))
        expect(Balanced::Debit).to receive(:find).and_return(existing_debit)
        expect(existing_debit).to receive(:refund).with({ amount: 1500 })

        expect(order.reload.payments.count).to eql(1)

        UpdateBalancedPurchase.perform(order: order)

        expect(order.reload.payments.count).to eql(2)
        expect(Payment.first.amount.to_f).to eql(45.00)
        expect(Payment.first.refunded_amount.to_f).to eql(15.00)
        expect(Payment.last.amount.to_f).to eql(-15.00)
      end

      it "against multiple payment" do
        create(:payment, :credit_card, orders: [order], amount: 45.00, balanced_uri: '/balanced-debit-2', status: 'failed')
        create(:payment, :credit_card, orders: [order], amount: 20.00, balanced_uri: '/balanced-debit-3')
        create(:payment, :credit_card, orders: [order], amount: 25.00, balanced_uri: '/balanced-debit-4')

        debit1 = double("balanced debit 1", amount: 4500, source: OpenStruct.new(_type: 'card'))
        debit3 = double("balanced debit 3", amount: 2000, source: OpenStruct.new(_type: 'card'))
        expect(Balanced::Debit).to receive(:find).with('/balanced-debit-1').and_return(debit1)
        expect(Balanced::Debit).to receive(:find).with('/balanced-debit-3').and_return(debit3)
        expect(Balanced::Debit).to_not receive(:find).with('/balanced-debit-4')
        expect(debit1).to receive(:refund).with({ amount: 4500 })
        expect(debit3).to receive(:refund).with({ amount: 1500 })

        expect(order.reload.payments.count).to eql(4)

        UpdateBalancedPurchase.perform(order: order)

        expect(order.reload.payments.count).to eql(6)
        expect(Payment.first.amount.to_f).to eql(45.00)
        expect(Payment.first.refunded_amount.to_f).to eql(45.00)
        expect(Payment.last.amount.to_f).to eql(-15.00)
      end

      it "records a failed refund when balanced fails" do
        existing_debit = double("balanced debit", amount: 4500, source: OpenStruct.new(_type: 'ach'))
        expect(Balanced::Debit).to receive(:find).and_return(existing_debit)
        expect(existing_debit).to receive(:refund).and_throw(Exception)

        expect(order.reload.payments.count).to eql(1)

        UpdateBalancedPurchase.perform(order: order)

        expect(order.reload.payments.count).to eql(2)
        expect(Payment.first.amount.to_f).to eql(45.00)
        expect(Payment.first.refunded_amount.to_f).to eql(0.00)
        expect(Payment.last.amount.to_f).to eql(-15.00)
        expect(Payment.last.status).to eql("failed")
      end
    end

    context "charge difference" do
      let!(:payment) { create(:payment, :checking, orders: [order], amount: 15.00) }

      it "charges the difference when the order amount goes up" do
        existing_debit = double("balanced debit", account: OpenStruct.new(uri: '/balanced-account-uri'), source: OpenStruct.new(_type: 'ach', uri: '/balanced-source-uri'))
        balanced_customer = double("balanced_customer")
        expect(Balanced::Debit).to receive(:find).and_return(existing_debit)
        expect(Balanced::Customer).to receive(:find).with('/balanced-account-uri').and_return(balanced_customer)
        expect(balanced_customer).to receive(:debit).with({amount: 1500, source_uri: '/balanced-source-uri', description: "#{market.name} purchase"})

        expect(order.reload.payments.count).to eql(1)

        UpdateBalancedPurchase.perform(order: order)

        expect(order.reload.payments.count).to eql(2)
        expect(Payment.first.amount.to_f).to eql(15.00)
        expect(Payment.last.amount.to_f).to eql(15.00)
      end

      it "records a failed charge when balanced fails" do
        existing_debit = double("balanced debit", account: OpenStruct.new(uri: '/balanced-account-uri'), source: OpenStruct.new(_type: 'ach', uri: '/balanced-source-uri'))
        balanced_customer = double("balanced_customer")
        expect(Balanced::Debit).to receive(:find).and_return(existing_debit)
        expect(Balanced::Customer).to receive(:find).with('/balanced-account-uri').and_return(balanced_customer)
        expect(balanced_customer).to receive(:debit).and_throw(Exception)

        expect(order.reload.payments.count).to eql(1)

        UpdateBalancedPurchase.perform(order: order)

        expect(order.reload.payments.count).to eql(2)
        expect(Payment.last.amount.to_f).to eql(15.00)
        expect(Payment.last.status).to eql("failed")
      end
    end
  end
end
