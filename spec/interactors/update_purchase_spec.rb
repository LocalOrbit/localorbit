require "spec_helper"

describe UpdatePurchase do
  let!(:market)            { create(:market) }
  let!(:delivery_schedule) { create(:delivery_schedule, fee: 0.0, fee_type: "fixed") }
  let!(:delivery)          { delivery_schedule.next_delivery }
  let!(:buyer)             { create(:organization, balanced_customer_uri: "/balanced-account-uri") }

  let!(:order_item) { create(:order_item, unit_price: 15.00, quantity: 2) }

  let(:existing_debit) { double("balanced debit", amount: 4500) }
  let(:balanced_customer) { double("balanced_customer") }

  let(:payment_provider) { PaymentProvider::Balanced.id }

  subject { described_class.perform(order: order) }

  context "credit card" do
    let!(:order) { create(:order, organization: buyer, delivery: delivery, market: market, items: [order_item], payment_method: "credit card", total_cost: 30.00, payment_provider: payment_provider) }
    let!(:bank_account) { create(:bank_account, :credit_card, bankable: buyer, balanced_uri: "/balanced-card-uri") }

    context "without any items" do
      let!(:payment) { create(:payment, :credit_card, bank_account: bank_account, orders: [order], amount: 45.00, balanced_uri: "/balanced-debit-1") }

      before do
        order.items.delete_all
        order.save!
      end

      it "refunds the entire amount" do
        expect(Balanced::Transaction).to receive(:find).and_return(existing_debit)
        expect(existing_debit).to receive(:refund).with(amount: 4500)

        expect(order.reload.payments.count).to eql(1)

        subject

        expect(order.reload.payments.count).to eql(2)
        expect(order.total_cost.to_f).to eql(0.0)
        expect(Payment.first.amount.to_f).to eql(45.00)
        expect(Payment.first.refunded_amount.to_f).to eql(45.00)
        expect(Payment.last.amount.to_f).to eql(-45.00)
      end
    end

    context "refund difference" do
      let!(:payment) { create(:payment, :credit_card, bank_account: bank_account, orders: [order], amount: 45.15, balanced_uri: "/balanced-debit-1") }
      let!(:market_payment) { create(:payment, :market_orders, orders: [order], amount: 86.00, balanced_uri: "/balanced-credit-1") }

      it "against one payment" do
        expect(Balanced::Transaction).to receive(:find).and_return(existing_debit)
        expect(existing_debit).to receive(:refund).with(amount: 1515)

        expect(order.reload.payments.count).to eql(2)

        subject

        expect(order.reload.payments.count).to eql(3)
        expect(Payment.first.amount.to_f).to eql(45.15)
        expect(Payment.first.refunded_amount.to_f).to eql(15.15)
        expect(Payment.last.amount.to_f).to eql(-15.15)
      end

      it "against multiple payment" do
        create(:payment, :checking, bank_account: bank_account, orders: [order], amount: 45.00, balanced_uri: "/balanced-debit-2", status: "failed")
        create(:payment, :checking, bank_account: bank_account, orders: [order], amount: 20.00, balanced_uri: "/balanced-debit-3")
        create(:payment, :checking, bank_account: bank_account, orders: [order], amount: 25.00, balanced_uri: "/balanced-debit-4")

        debit1 = double("balanced debit 1", amount: 4515)
        debit3 = double("balanced debit 3", amount: 2000)
        expect(Balanced::Transaction).to receive(:find).with("/balanced-debit-1").and_return(debit1)
        expect(Balanced::Transaction).to receive(:find).with("/balanced-debit-3").and_return(debit3)
        expect(Balanced::Transaction).to_not receive(:find).with("/balanced-debit-4")
        expect(debit1).to receive(:refund).with(amount: 4515)
        expect(debit3).to receive(:refund).with(amount: 1500)

        expect(order.reload.payments.count).to eql(5)

        subject

        payments = order.payments.buyer_payments.order(:id)
        expect(payments.size).to eql(6)

        # Initial payment
        expect(payments[0].amount).to eql(45.15)
        expect(payments[0].refunded_amount).to eql(45.15)

        # Failed payment
        expect(payments[1].amount).to eql(45.00)
        expect(payments[1].refunded_amount).to eql(0)

        # Additional payment
        expect(payments[2].amount).to eql(20.00)
        expect(payments[2].refunded_amount).to eql(15.0)

        # Another additional payment
        expect(payments[3].amount).to eql(25.00)
        expect(payments[3].refunded_amount).to eql(0)

        # Refund against initial payment
        expect(payments[4].payment_type).to eql("order refund")
        expect(payments[4].amount).to eql(-45.15)
        expect(payments[4].refunded_amount).to eql(0)

        # Refund against additional payment
        expect(payments[5].payment_type).to eql("order refund")
        expect(payments[5].amount).to eql(-15.0)
        expect(payments[5].refunded_amount).to eql(0)
      end

      it "against multiple payments and failing after the first payment", truncate: true do
        create(:payment, :checking, bank_account: bank_account, orders: [order], amount: 45.00, balanced_uri: "/balanced-debit-2", status: "failed")
        create(:payment, :checking, bank_account: bank_account, orders: [order], amount: 20.00, balanced_uri: "/balanced-debit-3")
        create(:payment, :checking, bank_account: bank_account, orders: [order], amount: 25.00, balanced_uri: "/balanced-debit-4")

        debit1 = double("balanced debit 1", amount: 4515)
        debit3 = double("balanced debit 3", amount: 2000)
        expect(Balanced::Transaction).to receive(:find).with("/balanced-debit-1").and_return(debit1)
        expect(Balanced::Transaction).to receive(:find).with("/balanced-debit-3").and_return(debit3)
        expect(Balanced::Transaction).to_not receive(:find).with("/balanced-debit-4")
        expect(debit1).to receive(:refund).with(amount: 4515)
        expect(debit3).to receive(:refund).with(amount: 1500).and_raise(StandardError)

        expect(order.reload.payments.count).to eql(5)

        subject

        payments = order.payments.buyer_payments.order(:id)
        expect(payments.size).to eql(6)

        # Initial payment
        expect(payments[0].amount).to eql(45.15)
        expect(payments[0].refunded_amount).to eql(45.15)

        # Failed payment
        expect(payments[1].amount).to eql(45.00)
        expect(payments[1].refunded_amount).to eql(0)

        # Additional payment
        expect(payments[2].amount).to eql(20.00)
        expect(payments[2].refunded_amount).to eql(0)

        # Another additional payment
        expect(payments[3].amount).to eql(25.00)
        expect(payments[3].refunded_amount).to eql(0)

        # Refund against initial payment
        expect(payments[4].payment_type).to eql("order refund")
        expect(payments[4].amount).to eql(-45.15)
        expect(payments[4].refunded_amount).to eql(0)

        # Refund against additional payment
        expect(payments[5].payment_type).to eql("order refund")
        expect(payments[5].amount).to eql(-15.0)
        expect(payments[5].refunded_amount).to eql(0)
        expect(payments[5].status).to eq("failed")
      end

      it "records a failed refund when balanced fails" do
        expect(Balanced::Transaction).to receive(:find).and_return(existing_debit)
        expect(existing_debit).to receive(:refund).and_raise(StandardError)

        expect(order.reload.payments.count).to eql(2)

        subject

        expect(order.reload.payments.count).to eql(3)
        expect(Payment.first.amount.to_f).to eql(45.15)
        expect(Payment.last.amount.to_f).to eql(-15.15)
        expect(Payment.last.status).to eql("failed")
      end
    end

    context "charge difference" do
      let!(:payment) { create(:payment, :credit_card, bank_account: bank_account, orders: [order], amount: 15.00) }

      it "charges the difference when the order amount goes up" do
        expect(Balanced::Customer).to receive(:find).with("/balanced-account-uri").and_return(balanced_customer)
        expect(balanced_customer).to receive(:debit).with(amount: 1500, source_uri: "/balanced-card-uri", description: "#{market.name} purchase", appears_on_statement_as: market.name, meta: {"order number" => order.order_number})

        expect(order.reload.payments.count).to eql(1)

        subject

        expect(order.reload.payments.count).to eql(2)
        expect(Payment.first.amount.to_f).to eql(15.00)
        expect(Payment.last.amount.to_f).to eql(15.00)
      end

      it "records a failed charge when balanced fails" do
        expect(Balanced::Customer).to receive(:find).with("/balanced-account-uri").and_return(balanced_customer)
        expect(balanced_customer).to receive(:debit).and_raise(StandardError)

        expect(order.reload.payments.count).to eql(1)

        subject

        expect(order.reload.payments.count).to eql(2)
        expect(Payment.last.amount.to_f).to eql(15.00)
        expect(Payment.last.status).to eql("failed")
      end
    end
  end

  context "ach" do
    let!(:order)      { create(:order, organization: buyer, delivery: delivery, market: market, items: [order_item], payment_method: "ach", total_cost: 30.00, payment_provider: payment_provider) }
    let!(:bank_account) { create(:bank_account, :checking, :verified, bankable: buyer, balanced_uri: "/balanced-bank-account-uri") }

    context "refund difference" do
      let!(:payment) { create(:payment, :checking, bank_account: bank_account, orders: [order], amount: 45.00, balanced_uri: "/balanced-debit-1") }

      it "against one payment" do
        expect(Balanced::Transaction).to receive(:find).and_return(existing_debit)
        expect(existing_debit).to receive(:refund).with(amount: 1500)

        expect(order.reload.payments.count).to eql(1)

        subject

        expect(order.reload.payments.count).to eql(2)
        expect(Payment.first.amount.to_f).to eql(45.00)
        expect(Payment.first.refunded_amount.to_f).to eql(15.00)
        expect(Payment.last.amount.to_f).to eql(-15.00)
      end

      it "against multiple payment" do
        create(:payment, :credit_card, bank_account: bank_account, orders: [order], amount: 45.00, balanced_uri: "/balanced-debit-2", status: "failed")
        create(:payment, :credit_card, bank_account: bank_account, orders: [order], amount: 20.00, balanced_uri: "/balanced-debit-3")
        create(:payment, :credit_card, bank_account: bank_account, orders: [order], amount: 25.00, balanced_uri: "/balanced-debit-4")

        debit1 = double("balanced debit 1", amount: 4500)
        debit3 = double("balanced debit 3", amount: 2000)
        expect(Balanced::Transaction).to receive(:find).with("/balanced-debit-1").and_return(debit1)
        expect(Balanced::Transaction).to receive(:find).with("/balanced-debit-3").and_return(debit3)
        expect(Balanced::Transaction).to_not receive(:find).with("/balanced-debit-4")
        expect(debit1).to receive(:refund).with(amount: 4500)
        expect(debit3).to receive(:refund).with(amount: 1500)

        expect(order.reload.payments.count).to eql(4)

        subject

        expect(order.reload.payments.count).to eql(6)
        expect(Payment.first.amount.to_f).to eql(45.00)
        expect(Payment.first.refunded_amount.to_f).to eql(45.00)
        expect(Payment.last.amount.to_f).to eql(-15.00)
      end

      it "records a failed refund when balanced fails" do
        expect(Balanced::Transaction).to receive(:find).and_return(existing_debit)
        expect(existing_debit).to receive(:refund).and_raise(StandardError)

        expect(order.reload.payments.count).to eql(1)

        subject

        expect(order.reload.payments.count).to eql(2)
        expect(Payment.first.amount.to_f).to eql(45.00)
        expect(Payment.first.refunded_amount.to_f).to eql(0.00)
        expect(Payment.last.amount.to_f).to eql(-15.00)
        expect(Payment.last.status).to eql("failed")
      end
    end

    context "charge difference" do
      let!(:payment) { create(:payment, :checking, bank_account: bank_account, orders: [order], amount: 15.00) }

      it "charges the difference when the order amount goes up" do
        expect(Balanced::Customer).to receive(:find).with("/balanced-account-uri").and_return(balanced_customer)
        expect(balanced_customer).to receive(:debit).with(amount: 1500, source_uri: "/balanced-bank-account-uri", description: "#{market.name} purchase", appears_on_statement_as: market.name, meta: {"order number" => order.order_number})

        expect(order.reload.payments.count).to eql(1)

        subject

        expect(order.reload.payments.count).to eql(2)
        expect(Payment.first.amount.to_f).to eql(15.00)
        expect(Payment.last.amount.to_f).to eql(15.00)
      end

      it "records a failed charge when balanced fails" do
        expect(Balanced::Customer).to receive(:find).with("/balanced-account-uri").and_return(balanced_customer)
        expect(balanced_customer).to receive(:debit).and_raise(StandardError)

        expect(order.reload.payments.count).to eql(1)

        subject

        expect(order.reload.payments.count).to eql(2)
        expect(Payment.last.amount.to_f).to eql(15.00)
        expect(Payment.last.status).to eql("failed")
      end
    end
  end
end
