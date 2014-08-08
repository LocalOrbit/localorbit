require 'spec_helper'

describe AttemptBalancedPurchase do
  let!(:market)      { create(:market) }
  let!(:delivery_schedule) { create(:delivery_schedule) }
  let!(:delivery)    { delivery_schedule.next_delivery }

  let!(:user)        { create(:user) }
  let!(:buyer)       { create(:organization) }
  let!(:product)     { create(:product, :sellable, organization: buyer) }
  let!(:bank_account) { create(:bank_account, :checking, bankable: buyer, balanced_uri: "/balanced-card-uri") }
  let!(:credit_card) { create(:bank_account, :credit_card, bankable: buyer, balanced_uri: "/balanced-credit-card-uri") }

  let!(:cart_item)   { create(:cart_item, product: product, quantity: 10)}
  let(:cart)        { create(:cart, organization: buyer, market: market, items: [cart_item]) }

  let!(:order)       { create(:order, :with_items, delivery: delivery) }
  let(:params)       { { "payment_method" => "purchase order"} }

  let!(:balanced_customer) { double("balanced customer", debit: balanced_debit) }
  let!(:balanced_debit)    { double("balanced debit", uri: "/balanced-debit-uri") }

  subject {
    AttemptBalancedPurchase.perform(buyer: user, order: order, order_params: params, cart: cart)
  }

  context "purchase order" do
    let(:params) { { "payment_method" => "purchase order" } }
    it "noop's" do
      expect(subject).to be_success
    end
  end

  context "ach" do
    let!(:params) { { "payment_method" => "ach", "bank_account" => "#{bank_account.id}" } }

    before do
      allow(Balanced::Customer).to receive(:find).and_return(balanced_customer)
    end

    context "valid bank account" do
      context "successfully debits bank account" do
        it "creates a payment record" do
          expect {
            subject
          }.to change {
            Payment.all.count
          }.from(0).to(1)

          expect(subject.context).to include(:payment)
          expect(order.reload.payments).to include(subject.context[:payment])
        end

        it "sets the payment's payer to the cart's organization" do
          subject # run the interactor

          payment = subject.context[:payment]
          payer = payment.reload.payer

          expect(payer).to eq(buyer)
          expect(payer.class).to eq(Organization)
        end

        it "sets the payment method on the order" do
          expect {
            subject
          }.to change {
            order.reload.payment_method
          }.from("purchase order").to("ach")
        end

        it "sets the payment status on the order" do
          expect {
            subject
          }.to change {
            order.reload.payment_status
          }.from("unpaid").to("pending")
        end

        it "creates a debit for the order amount" do
          expect(subject).to be_success
          expect(balanced_customer).to have_received(:debit).with(
            amount: (cart.total*100).to_i,
            source_uri: bank_account.balanced_uri,
            description: "#{cart.market.name} purchase"
          )
        end
      end

      context "fails to debit bank account" do
        before do
          expect(balanced_customer).to receive(:debit).and_raise(RuntimeError)
        end

        it "returns as a failure" do
          expect(subject).to be_failure
        end

        it "does not modify the order" do
          expect {
            subject
          }.to_not change {
            Payment.all.count
          }.from(0)
        end
      end

      context "zero dollar purchase" do
        let!(:cart) { create(:cart, organization: buyer, market: market, items: []) }

        it "creates a payment record" do
          expect {
            subject
          }.to change {
            Payment.all.count
          }.from(0).to(1)

          expect(subject.context).to include(:payment)
          expect(order.reload.payments).to include(subject.context[:payment])
        end

        it "sets the payment's payer to the cart's organization" do
          subject # run the interactor

          payment = subject.context[:payment]
          payer = payment.reload.payer

          expect(payer).to eq(buyer)
          expect(payer.class).to eq(Organization)
        end

        it "sets the payment method on the order" do
          expect {
            subject
          }.to change {
            order.reload.payment_method
          }.from("purchase order").to("ach")
        end

        it "sets the payment status on the order" do
          expect {
            subject
          }.to change {
            order.reload.payment_status
          }.from("unpaid").to("paid")
        end

        it "does not create a balanced debit" do
          expect(subject).to be_success
          expect(balanced_customer).to_not have_received(:debit)
        end
      end
    end

    context "invalid bank account" do
      let!(:params) { { "payment_method" => "ach", "bank_account" => "0" } }

      before do
        allow(Balanced::Customer).to receive(:debit).and_raise(RuntimeError)
      end

      it "returns as a failure" do
        expect(subject).to be_failure
      end

      it "does not record a payment" do
        expect {
          subject
        }.to_not change {
          Payment.all.count
        }.from(0)
      end
    end
  end

  context "credit card" do
    let!(:params) { { "payment_method" => "credit card", "credit_card" => {"id" => "#{credit_card.id}"} } }

    before do
      allow(Balanced::Customer).to receive(:find).and_return(balanced_customer)
    end

    context "valid credit card" do
      context "successfully creates a debit" do
        it "creates a payment record" do
          expect {
            subject
          }.to change {
            Payment.all.count
          }.from(0).to(1)

          expect(subject.context).to include(:payment)
          expect(order.reload.payments).to include(subject.context[:payment])
        end

        it "sets the payment method on the order" do
          expect {
            subject
          }.to change {
            order.reload.payment_method
          }.from("purchase order").to("credit card")
        end

        it "sets the payment status on the order" do
          expect {
            subject
          }.to change {
            order.reload.payment_status
          }.from("unpaid").to("paid")
        end

        it "creates a hold for the order amount" do
          expect(subject).to be_success
          expect(balanced_customer).to have_received(:debit).with(amount: (cart.total*100).to_i, description: "#{market.name} purchase", source_uri: credit_card.balanced_uri)
        end
      end

      context "fails to create a debit" do
        before do
          expect(balanced_customer).to receive(:debit).and_raise(RuntimeError)
        end

        it "returns as a failure" do
          expect(subject).to be_failure
        end

        it "does not create a payment record" do
          subject

          expect(Payment.all.count).to eql(0)
        end
      end

      context "zero dollar purchase" do
        let!(:cart) { create(:cart, organization: buyer, market: market, items: []) }

        it "creates a payment record" do
          expect {
            subject
          }.to change {
            Payment.all.count
          }.from(0).to(1)

          expect(subject.context).to include(:payment)
          expect(order.reload.payments).to include(subject.context[:payment])
        end

        it "sets the payment's payer to the cart's organization" do
          subject # run the interactor

          payment = subject.context[:payment]
          payer = payment.reload.payer

          expect(payer).to eq(buyer)
          expect(payer.class).to eq(Organization)
        end

        it "sets the payment method on the order" do
          expect {
            subject
          }.to change {
            order.reload.payment_method
          }.from("purchase order").to("credit card")
        end

        it "sets the payment status on the order" do
          expect {
            subject
          }.to change {
            order.reload.payment_status
          }.from("unpaid").to("paid")
        end

        it "does not create a balanced debit" do
          expect(subject).to be_success
          expect(balanced_customer).to_not have_received(:debit)
        end
      end
    end

    context "invalid credit card" do
      let!(:params) { { "payment_method" => "credit card", "credit_card" => "0" } }

      before do
        allow(Balanced::Customer).to receive(:find).and_raise(RuntimeError)
      end

      it "returns as a failure" do
        expect(subject).to be_failure
      end
    end
  end
end
