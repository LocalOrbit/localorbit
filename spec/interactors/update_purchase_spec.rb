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
    let(:mm_order1_item2) { create(:order_item, product: sally_product2, quantity: 2, unit_price: "9.5".to_d) }
    # Setup realistic-looking payments for the items:
    let(:order1_payment1) { create(:payment, :credit_card, amount: "15".to_d, stripe_payment_fee: "0.74".to_d, bank_account: credit_card) }
    let(:order1_payment2) { create(:payment, :credit_card, amount: "10".to_d, stripe_payment_fee: "0.59".to_d, bank_account: credit_card) }

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

    subject { described_class.perform(order: order, merge: nil) }

    context "without any items" do
      # before do
      #   order.items.delete_all
      #   order.save!
      # end

      it "refunds the entire amount"
    end

    context "when less was delivered than was ordered" do
      before do
        mm_order1_item2.update quantity_delivered: 1
        mm_order1_item1.update quantity_delivered: 1
        order.save # update total cost
      end
      it "creates a refund" do
        existing_payments = order.payments.order(created_at: :desc)
        # expect(existing_payments.sort_by(&:id)).to eq [order1_payment1,order1_payment2]
        expect(existing_payments).to eq [
          order1_payment2, 
          order1_payment1
        ]

        subject

        order.reload
        expect(order.total_cost).to eq "12.50".to_d
        expect(order.payments.sum(:amount)).to eq "12.50".to_d
        expect(order.payments.count).to eq 4

        refund_payments = order.payments.to_a.select do |p| p.payment_type == 'order refund' end.sort_by(&:id)

        rp1 = refund_payments[0]
        expect(rp1.amount).to eq("-10.0".to_d)
        expect(rp1.status).to eq "paid"
        expect(rp1.parent).to eq order1_payment2

        rp2 = refund_payments[1]
        expect(rp2.amount).to eq("-2.50".to_d)
        expect(rp2.status).to eq "paid"
        expect(rp2.parent).to eq order1_payment1

      end
    end

    context "when more quantity is added" do
      it "creates additional charges" 
    end


  end
end
