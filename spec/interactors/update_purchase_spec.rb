require "spec_helper"

describe UpdatePurchase do
  context "with Stripe" do
    include_context "the mini market"

    let(:payment_provider) { PaymentProvider::Stripe.id }

    before(:all) {
      VCR.turn_off!
      StripeMock.start
    }
    after(:all) {
      StripeMock.stop
      VCR.turn_on!
    }

    let!(:stripe_account) { get_or_create_stripe_account_for_market(mini_market) }
    let!(:stripe_customer) { create_stripe_customer organization: buyer_organization }
    let!(:credit_card) { create_and_attach_stripe_credit_card organization: buyer_organization, stripe_customer: stripe_customer }

    let(:order) { mm_order1 } # from mini market

    let(:mm_order1_item2) { create(:order_item, product: sally_product2, quantity: 2, unit_price: "9.5".to_d) }
    let(:order1_payment1) { create(:payment, :credit_card, amount: "15".to_d, stripe_payment_fee: "0.74".to_d, bank_account: credit_card) }
    let(:order1_payment2) { create(:payment, :credit_card, amount: "10".to_d, stripe_payment_fee: "0.59".to_d, bank_account: credit_card) }

    subject(:context) { described_class.perform(order: order, merge: nil) }

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
          statement_descriptor_suffix: mini_market.on_statement_as)
        payment.update stripe_id: charge.id
        charge
      end

      retro_charge.call order1_payment1
      retro_charge.call order1_payment2

      # Setup order1 to have two items:
      #   mm_order1_item1 amounts to 6.00
      #   mm_order1_item2 amounts to 19.00
      #   total 25.00
      #   payment fees: 1.03
      order.items << mm_order1_item2
      order.payments << order1_payment1
      order.payments << order1_payment2
      order.save # update total cost
    end

    context "when less was delivered than was ordered" do
      before do
        mm_order1_item2.update quantity_delivered: 1
        mm_order1_item1.update quantity_delivered: 1
        order.save # update total cost
      end

      it 'succeeds' do
        skip 'stripe-ruby-mock has bug where get_charge is returning application_fee as int not Object'
        expect(context).to be_a_success
      end

      it 'sends the correct refund_charges to PaymentProvider' do
        expect(PaymentProvider).to receive(:refund_charge).with(:stripe,
          hash_including(order: order, amount: 10.0))
        expect(PaymentProvider).to receive(:refund_charge).with(:stripe,
          hash_including(order: order, amount: 2.5))

        # TODO: These two lines are redundant and to workaround a Stripe Mock issue where
        # the charge.application_fee is coming back as a int, not a Fee object.
        expect(PaymentProvider).to receive(:create_refund_payment).with(:stripe,
          hash_including(order: order, amount: -10.0))
        expect(PaymentProvider).to receive(:create_refund_payment).with(:stripe,
          hash_including(order: order, amount: -2.5))

        subject
      end
    end
  end
end
