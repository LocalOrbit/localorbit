describe PaymentProvider::Stripe do
  subject { described_class } 

  describe ".supported_payment_methods" do
    it "has 'credit card'" do
      expect(subject.supported_payment_methods).to eq ['credit card']
    end
  end

  describe ".place_order" do
    let(:params) {
      { 
        buyer_organization: "the buyer org",
        user: "the user",
        order_params: "the order params",
        cart: "the cart" 
      }
    }

    it "invokes PlaceOrder interactor" do
      expect(PlaceStripeOrder).to receive(:perform).with(
        payment_provider: :stripe,
        entity: params[:buyer_organization],
        buyer: params[:user],
        order_params: params[:order_params],
        cart: params[:cart]
      )

      subject.place_order(params)
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
        translated = subject.translate_status(charge: charge, cart: 'wat', payment_method: 'evar')
        expect(translated).to eq(output), "Expected status '#{input}' to translate to '#{output}' but got '#{translated}'"
      end
    end

    it "returns 'failed' for nil charge" do
      translated = subject.translate_status(charge: nil, cart: 'wat', payment_method: 'evar')
      expect(translated).to eq('failed')
    end
  end

  describe ".charge_for_order" do
    include_context "the mini market"

    let(:cart)      { create(:cart, organization: buyer_organization) }
    let(:credit_card) { create(:bank_account, :credit_card) }
    let(:order) { mm_order1 } # from mini market
    
    let(:payment_method) { "credit card" }
    let(:amount) { "100.00".to_d }

    let(:stripe_card_token) {
      Stripe::Token.create(
        card: {
          number: "4012888888881881", 
          exp_month: 5, 
          exp_year: 2016, 
          cvc: "314"
        }
      )
    }

    let(:stripe_customer) { Stripe::Customer.create(
        description: buyer_organization.name,
        metadata: {
          "lo.entity_id" => buyer_organization.id,
          "lo.entity_type" => 'organization'
        }
      ) 
    }
    let(:stripe_account) { 
      acct = Stripe::Account.all(limit:100).detect { |a| a.email == mini_market.contact_email }
      if acct
        acct
      else
        Stripe::Account.create(
          managed: true,
          country: 'US',
          email: mini_market.contact_email
        )
      end
    }

    before do
      VCR.turn_off!

      track_stripe_object_for_cleanup stripe_customer
      
      # Connect Barry to his Stripe customer...
      buyer_organization.update(stripe_customer_id: stripe_customer.id)
      # ...and his credit card:
      stripe_card = stripe_customer.sources.create(source: stripe_card_token.id)
      credit_card.update(stripe_id: stripe_card.id)
      buyer_organization.bank_accounts << credit_card

      # Connect Market to its Stripe account:
      mini_market.update(stripe_account_id: stripe_account.id)
    end

    after do
      cleanup_stripe_objects
      VCR.turn_on!
    end

    it "creates a Stripe charge" do
      charge = subject.charge_for_order(
        amount: amount,
        bank_account: credit_card,
        market: mini_market,
        order: order,
        buyer_organization: buyer_organization)

      expected_amount = ::Financials::MoneyHelpers.amount_to_cents(amount)
      estimated_fee = ::PaymentProvider::FeeEstimator.estimate_payment_fee PaymentProvider::Stripe::CreditCardFeeStructure, expected_amount

      expect(charge).to be
      expect(charge.status).to eq 'succeeded'
      expect(charge.amount).to eq expected_amount
      expect(charge.currency).to eq 'usd'
      expect(charge.source.id).to eq credit_card.stripe_id
      expect(charge.customer).to eq buyer_organization.stripe_customer_id
      expect(charge.destination).to eq mini_market.stripe_account_id
      expect(charge.application_fee).to be

      app_fee = Stripe::ApplicationFee.retrieve(charge.application_fee)
      expect(app_fee).to be
      expect(app_fee.amount).to eq estimated_fee
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

        ref = subject.fully_refund(
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

        ref = subject.fully_refund(
          payment: payment,
          order: order
        )

        expect(ref).to be new_refund
      end
    end # end interaction tests

  end

end
