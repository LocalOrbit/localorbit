require 'spec_helper'

describe PaymentProvider::Stripe do

  before(:all) {
    VCR.turn_off!
    StripeMock.start
  }
  after(:all) {
    StripeMock.stop
    VCR.turn_on!
  }

  describe ".supported_payment_methods" do
    it "has 'credit card'" do
      expect(described_class.supported_payment_methods).to eq ['credit card']
    end
  end

  describe ".default_currency_for_country(country)" do
    it "returns the correct currency" do
      expect(described_class.default_currency_for_country('US')).to eq 'USD'
      expect(described_class.default_currency_for_country('CA')).to eq 'CAD'
      expect { described_class.default_currency_for_country('Gondor')}.to raise_error(ArgumentError, 'Gondor is not a supported country.')
    end
  end

  describe ".place_order" do
    let(:params) {
      {
        buyer_organization: "the buyer org",
        user: "the user",
        order_params: "the order params",
        cart: "the cart",
        request: "the request"
      }
    }

    it "invokes PlaceOrder interactor" do
      expect(PlaceStripeOrder).to receive(:perform).with(
        payment_provider: PaymentProvider::Stripe.id.to_s,
        entity: params[:buyer_organization],
        user: params[:user],
        order_params: params[:order_params],
        cart: params[:cart],
        request: params[:request]
      )

      described_class.place_order(params)
    end
  end

  describe ".translate_status" do
    it "maps 'pending' to 'pending' and 'succeeded' to 'paid' and anything else to 'failed'" do
      expectations = {
        'pending' => 'pending',
        'succeeded' => 'paid',
        'failed' => 'failed',
        'other' => 'failed',
        '_nil_' => 'failed'
      }
      expectations.each do |input,output|
        input = nil if input == '_nil_'
        charge = create_stripe_mock(:charge, status: input)
        translated = described_class.translate_status(charge: charge, amount:nil, payment_method:nil)
        expect(translated).to eq(output), "Expected status '#{input}' to translate to '#{output}' but got '#{translated}'"
      end
    end

    context "when charge is nil" do
      it "returns 'failed' for nil charge" do
        translated = described_class.translate_status(charge: nil, amount:nil, payment_method:"credit card")
        expect(translated).to eq('failed')
      end
      context "...and amount is 0 and payment_method is 'credit card'" do
        it "returns 'paid' for nil charge" do
          # This is part of the hokey dance of pretending 0-amount payments are paid.  See AttemptPurchase to
          # understand the context for this odd interpretation.
          translated = described_class.translate_status(charge: nil, amount:"0".to_d, payment_method:"credit card")
          expect(translated).to eq('paid')
        end
      end
    end
  end

  describe ".charge_for_order" do
    include_context "the mini market"

    let(:cart)      { create(:cart, organization: buyer_organization) }

    let!(:credit_card) {
      bank_account = create(:bank_account, :credit_card)
      create_stripe_credit_card(stripe_customer: stripe_customer, bank_account: bank_account)

      # Make sure Barry has the credit card
      buyer_organization.bank_accounts << bank_account

      bank_account
    }
    let(:order) { mm_order1 } # from mini market

    let(:payment_method) { "credit card" }
    let(:amount) { "100.00".to_d }

    let!(:stripe_customer) { create_stripe_customer(organization: buyer_organization) }

    let!(:stripe_account) { get_or_create_stripe_account_for_market(mini_market) }

    let(:charge_params) {{
      amount: amount,
      bank_account: credit_card,
      market: mini_market,
      order: order,
      buyer_organization: buyer_organization
    }}

    it "creates a Stripe charge" do
      create_charge_params = {
        amount: ::Financials::MoneyHelpers.amount_to_cents(charge_params[:amount]),
        currency: 'usd',
        source: charge_params[:bank_account].stripe_id,
        customer: buyer_organization.stripe_customer_id,
        transfer_data: {
          destination: charge_params[:market].stripe_account_id,
        },
        on_behalf_of: charge_params[:market].stripe_account_id,
        application_fee_amount: 320,
        description: "Charge for #{order.order_number}"
      }

      charge_double = double
      allow(charge_double).to receive(:transfer) { 'tr_123abc' }

      expect(::Stripe::Charge).to receive(:create)
        .with(hash_including(create_charge_params))
        .and_return(charge_double)

      transfer_double = double
      allow(transfer_double).to receive(:destination_payment) { 'py' }
      allow(transfer_double).to receive(:destination) { 'dest' }

      expect(::Stripe::Transfer).to receive(:retrieve)
        .with(charge_double.transfer)
        .and_return(transfer_double)

      payment_double = double
      allow(payment_double).to receive(:save)
      allow(payment_double).to receive(:[]).and_return({metadata: {}})

      expect(::Stripe::Charge).to receive(:retrieve)
        .and_return(payment_double)

      charge = described_class.charge_for_order(charge_params)

      # expected_amount = ::Financials::MoneyHelpers.amount_to_cents(amount)
      # estimated_fee = ::PaymentProvider::FeeEstimator.estimate_payment_fee PaymentProvider::Stripe::CreditCardFeeStructure, expected_amount

      # # Examine the Charge:
      # expect(charge).to be
      # expect(charge.status).to eq 'succeeded'
      # expect(charge.amount).to eq expected_amount
      # expect(charge.currency).to eq 'usd'
      # expect(charge.source.id).to eq credit_card.stripe_id
      # expect(charge.customer).to eq buyer_organization.stripe_customer_id
      # expect(charge.destination).to eq mini_market.stripe_account_id
      # expect(charge.description).to eq "Charge for #{order.order_number}"
      # expect(charge.application_fee).to be

      # # Examine the app fee:
      # app_fee = Stripe::ApplicationFee.retrieve(charge.application_fee)
      # expect(app_fee).to be
      # expect(app_fee.amount).to eq estimated_fee

      # # Find the associated Payment and check its metadata:
      # stripe_transfer = Stripe::Transfer.retrieve(charge.transfer)
      # stripe_payment = Stripe::Charge.retrieve(stripe_transfer.destination_payment, {stripe_account: stripe_transfer.destination})
      # expect(stripe_payment).to be
      # expect(stripe_payment["metadata"]).to be
      # expect(stripe_payment["metadata"]["lo.order_id"]).to eq order.id.to_s
      # expect(stripe_payment["metadata"]["lo.order_number"]).to eq order.order_number
    end

    context "when Stripe charge fails" do
      xit "recreates and raises the exception without a root cause (to dance around Honeybadger's unwrap_exception which occludes the cause." do
        StripeMock.prepare_card_error(:card_declined, :new_charge)

        expect(Stripe::Charge).to receive(:create).and_raise_error {|e|
          expect(e).to be_a Stripe::CardError
          expect(e.http_status).to eq(402)
          expect(e.code).to eq('card_declined')
        }

        begin
          described_class.charge_for_order(charge_params)
          raise ".charge_for_order should have raised an error"
        rescue StandardError => e
          expect(e.class).to be ::Stripe::StripeError
          expect(e.message).to eq "(Status 123) The message #{expected_data.to_json}"
        end

      end
    end

    context "when market has no stripe_account_id" do
      before { mini_market.update(stripe_account_id: nil) }
      it "raises an error" do
        begin
          described_class.charge_for_order(charge_params)
          raise ".charge_for_order should have raised an error"
        rescue StandardError => e
          # TODO: refactor this area, as the following hashes are duplicated in a few places in this file.
          expected_data = {
            charge_params: {
              amount: Financials::MoneyHelpers.amount_to_cents(amount),
              currency: 'usd',
              source: credit_card.stripe_id,
              customer: buyer_organization.stripe_customer_id,
              destination: mini_market.stripe_account_id,
              statement_descriptor_suffix: mini_market.on_statement_as,
              application_fee: 320, # mocked
              description: "Charge for #{order.order_number}"
            },
            metadata: {
              market: mini_market.name,
              market_id: mini_market.id,
              order_number: order.order_number,
              order_id: order.id,
              buyer_organization: buyer_organization.name,
              buyer_organization_id: buyer_organization.id,
              bank_account_id: credit_card.id,
              market_stripe_account: mini_market.stripe_account_id,
            }
          }
          # NOTE: This spec is somewhat fragile:
          # The precise string content of the exception is being asserted,
          # is dependent on the exact content AND KEY ORDERING of the hashes in
          # use in the method under test and in this test.
          expect(e.class).to be RuntimeError
          expect(e.message).to start_with("Can't create a Stripe charge")
        end
      end
    end
  end

  describe ".fully_refund" do
    context "(interaction tests)" do
      let(:payment) { double "the payment", stripe_id: "the payment stripe id" }
      let(:order) { double "the order", id: 'the order id', order_number: "the order number" }
      let(:charge) { double "the charge", refunds: refund_list }
      let(:refund_list) { double "the list of refunds" }
      let(:new_refund) { double "the new refund" }

      it "creates a refund on the given charge" do
        expect(refund_list).to receive(:create).with(
          refund_application_fee: true,
          reverse_transfer: true,
          metadata: {
            'lo.order_id' => order.id,
            'lo.order_number' => order.order_number,
          }
        ).and_return(new_refund)

        ref = described_class.fully_refund(
          charge: charge,
          payment: payment,
          order: order
        )

        expect(ref).to be new_refund
      end

      it "looks up the charge based on payment stripe_id if not provided as arg" do
        expect(Stripe::Charge).to receive(:retrieve).with(payment.stripe_id).and_return(charge)

        expect(refund_list).to receive(:create).with(
          refund_application_fee: true,
          reverse_transfer: true,
          metadata: {
            'lo.order_id' => order.id,
            'lo.order_number' => order.order_number,
          }
        ).and_return(new_refund)

        ref = described_class.fully_refund(
          payment: payment,
          order: order
        )

        expect(ref).to be new_refund
      end
    end # end interaction tests

  end

  describe ".store_payment_fees" do
    include_context "the mini market"

    let(:order1_item2) { create(:order_item, product: sally_product2, quantity: 2, unit_price: "9.5".to_d) }
    let(:order1_payment1) { create(:payment, :credit_card, amount: "10".to_d, stripe_payment_fee: "0.59".to_d) }
    let(:order1_payment2) { create(:payment, :credit_card, amount: "15.99".to_d, stripe_payment_fee: "0.76".to_d) }

    before do
      order1.items << order1_item2
      order1.payments << order1_payment1
      order1.payments << order1_payment2
    end

    # order1 now has 2 items:
    #   order1_item1 amounts to 6.99
    #   order1_item2 amounts to 19.00
    #   total 25.99
    #   payment fees: 1.35
    it "redistributes payment fees pro-rata to order items' payment_seller_fee" do
      expect(order1_item1.payment_seller_fee).to eq 0
      expect(order1_item2.payment_seller_fee).to eq 0

      res = described_class.store_payment_fees(order: order1)
      expect(res).to be nil

      expect(order1_item1.payment_seller_fee).to eq "0.36".to_d
      expect(order1_item2.payment_seller_fee).to eq "0.99".to_d
    end

    context "when Market pays payment fees" do
      before do
        mini_market.update(credit_card_seller_fee: "0".to_d, credit_card_market_fee: "3".to_d)
      end

      it "redistributes payment fees pro-rata to order items' payment_market_fee" do
        expect(order1_item1.payment_market_fee).to eq 0
        expect(order1_item2.payment_market_fee).to eq 0

        described_class.store_payment_fees(order: order1)

        expect(order1_item1.payment_market_fee).to eq "0.36".to_d
        expect(order1_item2.payment_market_fee).to eq "0.99".to_d
      end
    end
  end

  describe ".create_order_payment" do
    include_context "the mini market"

    let(:charge) { create_stripe_mock(:charge, id: 'the charge id', application_fee: 'the app fee id') }
    let(:app_fee) { create_stripe_mock(:application_fee, amount: 320, amount_refunded: 40) }
    let(:bank_account) { create(:bank_account, :credit_card) }
    let(:params) {
      {
        charge: charge,
        market_id: mini_market.id,
        bank_account: bank_account,
        payer: buyer_organization,
        payment_method: "credit card",
        amount: order1.gross_total,
        order: order1,
        status: 'paid'
      }
    }

    it "stores a Payment record corresponding to a charge" do
      expect(Stripe::ApplicationFee).to receive(:retrieve).with(charge.application_fee).and_return(app_fee)
      payment = described_class.create_order_payment(params)
      expect(payment).to be
      expect(payment.id).to be # stored to database
      expect(payment.market_id).to eq mini_market.id
      expect(payment.bank_account).to eq bank_account
      expect(payment.payer).to eq buyer_organization
      expect(payment.payment_method).to eq 'credit card'
      expect(payment.amount).to eq order1.gross_total
      expect(payment.payment_type).to eq 'order'
      expect(payment.orders).to eq [ order1 ]
      expect(payment.status).to eq 'paid'
      expect(payment.stripe_id).to eq charge.id
      expect(payment.stripe_payment_fee).to eq "2.80".to_d
      expect(payment.payment_provider).to eq 'stripe'
      expect(payment.payment_provider).to eq described_class.id.to_s
    end

    context "when the ApplicationFee is not found" do
      it "sets 0 for app fee" do
        expect(Stripe::ApplicationFee).to receive(:retrieve).with(charge.application_fee).and_return(nil)
        payment = described_class.create_order_payment(params)
        expect(payment.stripe_id).to eq charge.id
        expect(payment.stripe_payment_fee).to eq "0".to_d
      end
    end

    context "when the charge is nil" do
      it "leaves the stripe_id unset and sets 0 for app fee" do
        params[:charge] = nil
        payment = described_class.create_order_payment(params)
        expect(payment.stripe_id).to be nil
        expect(payment.stripe_payment_fee).to eq "0".to_d
      end
    end

  end

  describe ".create_refund_payment" do
    include_context "the mini market"

    let(:charge) { create_stripe_mock(:charge, id: 'the charge id', application_fee: 'the app fee id') }
    let(:app_fee) { create_stripe_mock(:application_fee, amount: 320, amount_refunded: 58) } # 58 cents refunded off of 320 is 262
    let(:bank_account) { create(:bank_account, :credit_card) }
    let(:refund) { create_stripe_mock(:refund, id: 'the refund id') }
    let(:parent_payment) { create(:payment, :credit_card, amount: "100".to_d, stripe_id: charge.id) }

    let(:params) {
      {
        charge: charge,
        market_id: mini_market.id,
        bank_account: bank_account,
        payer: buyer_organization,
        payment_method: "credit card",
        amount: "-20.0".to_d,
        order: order1,
        status: 'paid',
        refund: refund,
        parent_payment: parent_payment
      }
    }

    def create_refund_payment
      described_class.create_refund_payment(params)
    end


    it "stores a Payment record corresponding to a refund on a charge, parented to the original Payment instance" do
      expect(Stripe::ApplicationFee).to receive(:retrieve).with(charge.application_fee).and_return(app_fee)
      payment = create_refund_payment
      expect(payment).to be
      expect(payment.id).to be # stored to database
      expect(payment.market_id).to eq mini_market.id
      expect(payment.bank_account).to eq bank_account
      expect(payment.payer).to eq buyer_organization
      expect(payment.payment_method).to eq 'credit card'
      expect(payment.amount).to eq "-20.0".to_d
      expect(payment.payment_type).to eq 'order refund'
      expect(payment.orders).to eq [ order1 ]
      expect(payment.status).to eq 'paid'
      expect(payment.stripe_id).to eq charge.id # same charge reference as our parent
      expect(payment.stripe_payment_fee).to eq "0".to_d # no payment fees are recorded on the refund Payment
      expect(payment.stripe_refund_id).to eq refund.id
      expect(payment.payment_provider).to eq described_class.id.to_s

      expect(parent_payment.reload.stripe_payment_fee).to eq "2.62".to_d # 320 - 58 cents
    end

    context "when the ApplicationFee is not found" do
      it "sets 0 for app fee" do
        expect(Stripe::ApplicationFee).to receive(:retrieve).with(charge.application_fee).and_return(nil)
        payment = create_refund_payment
        expect(payment.stripe_id).to eq charge.id
        expect(payment.stripe_payment_fee).to eq "0".to_d
      end
    end

    context "when the refund is nil" do
      it "leaves the stripe_refund_id unset" do
        expect(Stripe::ApplicationFee).to receive(:retrieve).with(charge.application_fee).and_return(app_fee)
        params[:refund] = nil
        payment = create_refund_payment
        expect(payment.stripe_refund_id).to be nil
      end
    end

    context "when the charge is nil" do
      it "leaves the stripe_id unset and sets 0 for app fee" do
        params[:charge] = nil
        payment = create_refund_payment
        expect(payment.stripe_id).to be nil
        expect(payment.stripe_payment_fee).to eq "0".to_d
      end
    end

  end

  describe ".find_charge" do
    let(:payment) { double "the payment", stripe_id: 'the stripe id' }
    let(:charge) { double "the charge" }

    it "retrieves the Charge from Stripe per the stripe_id of the given Payment" do
      expect(Stripe::Charge).to receive(:retrieve).with(payment.stripe_id).and_return(charge)
      expect(described_class.find_charge(payment: payment)).to eq charge
    end
  end

  describe ".refund_charge" do
    let(:order) { double "an order", id: "the order id", order_number: "the order number" }
    let(:charge) { double "an charge", refunds: refunds_object }
    let(:amount) { "42.35".to_d }
    let(:refunds_object) { double "a list of refunds" }
    let(:refund) { double "a refund" }

    it "adds a refund to the charge based on the amount and order metadata, reversing the transfer" do
      expect(refunds_object).to receive(:create).with(
        amount: 4235,
        reverse_transfer: true,
        refund_application_fee: true,
        metadata: {
          'lo.order_id' => order.id,
          'lo.order_number' => order.order_number,
        }
      ).and_return refund

      expect(described_class.refund_charge(charge:charge, amount:amount, order:order)).to eq refund
    end

  end

  describe ".create_market_payment" do
    let!(:market) { create(:market) }
    let!(:bank_account) { create(:bank_account, bankable: market) }
    let!(:deposit_account) { create(:bank_account, bankable: market, account_role: 'deposit') }
    let!(:order1) { create(:order, market: market) }
    let!(:order2) { create(:order, market: market) }
    let(:orders) { [order1,order2] }
    let(:order_ids) { orders.map do |o| o.id end }

    let(:params) {{
      payout_id: 'the payout id',
      market: market,
      order_ids: order_ids,
      status: 'the status',
      amount: "12.34".to_d
    }}

    it "creates and returns a Payment record to track the Stripe payout and the involved Orders" do
      payment = described_class.create_market_payment(params)
      expect(payment).to be
      expect(payment.id).to be
      expect(payment.payment_type).to eq 'market payment'

      expect(payment.payee).to eq(market)
      expect(payment.market).to eq(market)
      expect(payment.order_ids.to_set).to eq(order_ids.to_set)
      expect(payment.stripe_transfer_id).to eq 'the payout id'
      expect(payment.status).to eq 'the status'
      expect(payment.amount).to eq '12.34'.to_d
      expect(payment.payment_provider).to eq PaymentProvider::Stripe.id.to_s
      expect(payment.bank_account).to eq deposit_account
    end

    describe "when an order id is given that doesn't refer to an actual order" do
      it "ignores the errant order id" do
        original_ids = params[:order_ids].dup
        params[:order_ids].push 1234
        params[:order_ids].unshift 187
        payment = described_class.create_market_payment(params)
        expect(payment.order_ids.to_set).to eq(original_ids.to_set)
      end
    end

  end

  describe ".create_stripe_card_for_stripe_customer" do
    let!(:stripe_customer) { create_stripe_customer(organization: create(:organization, :buyer)) }
    let!(:stripe_token) { create_stripe_token }

    it "makes a credit card" do
      credit_card = described_class.create_stripe_card_for_stripe_customer(
        stripe_customer_id: stripe_customer.id,
        stripe_tok: stripe_token.id
      )
      expect(credit_card).to be
    end

  end

  describe ".add_payment_method" do

    let(:params) do
      {
        entity: "foo bar",
        bank_account_params: "money",
        representative_params: "stuff"
      }
    end

    it "invokes AddStripeCreditCardToEntity" do
      expect(AddStripeCreditCardToEntity).to receive(:perform).with(params)
      described_class.add_payment_method(params.merge(type: "card"))
    end

    it "raises error for type not equal card" do
      expect(AddStripeCreditCardToEntity).not_to receive(:perform)

      expect {
        described_class.add_payment_method(params.merge(type: "checking"))
      }.to raise_error(/doesn't support/)
    end
  end

  describe "approximate_credit_card_fee" do
    it "appropriately gets credit card rate from Payment Provider" do
        expect(PaymentProvider::Stripe.approximate_credit_card_rate).to eq(PaymentProvider::Stripe::CreditCardFeeStructure[:rate])
    end
  end

  describe ".select_usable_bank_accounts" do
    let!(:cc1) { create(:bank_account, :credit_card, stripe_id: "sid1") }
    let!(:cc2) { create(:bank_account, :credit_card) }
    let!(:cc3) { create(:bank_account, :credit_card, stripe_id: "sid2") }
    let(:cards) { [ cc1,cc2,cc3] }

    it "returns only bank accounts with stripe_ids set" do
      expect(described_class.select_usable_bank_accounts(cards).to_set).to eq([cc1,cc3].to_set)
    end
  end
end

xdescribe PaymentProvider::Stripe, vcr: true do
  describe '.order_ids_for_market_payout_transfer' do
    # ISSUE: relies on data in test account that has changed
    # some `metadata: {lo.order_id: NNN}` is now missing on responses from Stripe
    it "returns lo order ids from a transaction's payments" do
      order_ids = described_class.order_ids_for_market_payout_transfer(
        payout_id: 'tr_15xxwkHouQbaP1MV8O0tEg2b', stripe_account_id: 'acct_15xJY9HouQbaP1MV')
      expect(order_ids).to eq([1234, 187, 1337])
    end
  end
end
