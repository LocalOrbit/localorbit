require "spec_helper"

describe UpdatePurchase do
  context "with Stripe" do
    include_context "the mini market"

    let(:payment_provider) { PaymentProvider::Stripe.id }

    before :all do VCR.turn_off!  end
    after :all do VCR.turn_on!  end

    let!(:stripe_account) { get_or_create_stripe_account_for_market(mini_market) }
    let!(:stripe_customer) { create_stripe_customer organization: buyer_organization }
    let!(:credit_card) { create_and_attach_stripe_credit_card organization: buyer_organization, stripe_customer: stripe_customer }

    let(:order) { mm_order1 } # from mini market

    # Add another item to the order:
    let(:order1_item2) { create(:order_item, product: sally_product2, quantity: 2, unit_price: "9.5".to_d) }
    # Setup realistic-looking payments for the items:
    let(:order1_payment1) { create(:payment, :credit_card, amount: "10".to_d, stripe_payment_fee: "0.59".to_d, bank_account: credit_card) }
    let(:order1_payment2) { create(:payment, :credit_card, amount: "15.99".to_d, stripe_payment_fee: "0.76".to_d, bank_account: credit_card) }

    before do
      order.update(
        payment_provider: payment_provider,  # Make sure the order has Stripe payment provider
        payment_method: 'credit card' # be sure the payment method is set properly
      )

      retro_charge = lambda do |payment|
        charge = Stripe::Charge.create(
          amount:          Financials::MoneyHelpers.amount_to_cents(payment.amount), 
          application_fee: Financials::MoneyHelpers.amount_to_cents(payment.stripe_payment_fee),
          currency: 'usd', 
          source: credit_card.stripe_id, 
          customer: stripe_customer.id,
          destination: mini_market.stripe_account_id, 
          statement_descriptor: mini_market.on_statement_as)
        payment.update stripe_id: charge.id
        charge
      end

      retro_charge.call order1_payment1
      retro_charge.call order1_payment2

      # Setup order1 to have two items:
      #   order1_item1 amounts to 6.99 
      #   order1_item2 amounts to 19.00
      #   total 25.99
      #   payment fees: 1.35
      order.items << order1_item2
      order.payments << order1_payment1
      order.payments << order1_payment2
      order.save # update total cost

    end

    subject { described_class.perform(order: order) }

    context "without any items" do
      # before do
      #   order.items.delete_all
      #   order.save!
      # end

      it "refunds the entire amount"
    end

    context "when less was delivered than was ordered" do
      before do
        order1_item2.update quantity_delivered: 1
        order.save # update total cost
      end
      it "creates a refund" do
        existing_payments = order.payments
        expect(existing_payments.sort_by(&:id)).to eq [order1_payment1,order1_payment2]

        subject

        order.reload
        expect(order.total_cost).to eq "15.50".to_d
        expect(order.payments.sum(:amount)).to eq "15.50".to_d
        expect(order.payments.count).to eq 4

        refund_payments = order.payments.to_a.select do |p| p.payment_type == 'order refund' end.sort_by(&:id)

        rp1 = refund_payments[0]
        expect(rp1.amount).to eq("-10.0".to_d)
        expect(rp1.status).to eq "paid"
        expect(rp1.parent).to eq order1_payment1

        rp2 = refund_payments[1]
        expect(rp2.amount).to eq("-0.49".to_d)
        expect(rp2.status).to eq "paid"
        expect(rp2.parent).to eq order1_payment2

      end

      it "spreads refund across multiple charges if necessary"
    end

    context "when more quantity is added" do
      it "creates additional charges" 
    end


  end
  
  context "with Balanced" do
    let(:payment_provider) { PaymentProvider::Balanced.id }
    let!(:market)            { create(:market) }
    let!(:delivery_schedule) { create(:delivery_schedule, fee: 0.0, fee_type: "fixed") }
    let!(:delivery)          { delivery_schedule.next_delivery }
    let!(:buyer)             { create(:organization, balanced_customer_uri: "/balanced-account-uri") }

    let!(:order_item) { create(:order_item, unit_price: 15.00, quantity: 2) }

    let(:existing_debit) { double("balanced debit", amount: 4500) }
    let(:balanced_customer) { double("balanced_customer") }


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
end
