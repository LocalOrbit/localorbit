describe AttemptPurchase do
  subject { described_class }

  context "making a purchase through Stripe" do
    include_context "the mini market"

    let(:cart) { 
      create(:cart, 
             organization: buyer_organization, 
             market: mini_market) 
    }

    let(:credit_card) { create(:bank_account, :credit_card) }
    let(:order) { mm_order1 } # from mini market
    
    let(:payment_method) { "credit card" }
    let(:amount) { "100.00".to_d }

    let(:stripe_card_token) { create_stripe_token }

    let(:stripe_customer) { create_stripe_customer organization: buyer_organization }
    
    let(:stripe_account) { get_or_create_stripe_account_for_market(mini_market) }

    let(:order_params) {
      HashWithIndifferentAccess.new(
        payment_method: payment_method,
        credit_card: { id: credit_card.id }
      )
    }

    let(:params) {
      {
        payment_provider: PaymentProvider::Stripe.id,
        cart: cart,
        order: order,
        order_params: order_params
      }
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

      # 
      # This could be a nasty shortcut, since Cart#total is a summation method
      # involving a bunch of CartItems and price schemes we don't have setup in
      # this test.  HOWEVER, it's very questionable that Cart should even be
      # USED by AttemptPurchase, since by the time AttemptPurchase is invoked,
      # CreateOrder has already transmuted all Cart data into an Order.
      # Consider dropping Cart usage altogether withing the AttemptPurchase
      # interactor. For now, let's just hotwire #total and move on.  
      #      -- crosby 5/7/2015
      #
      allow(cart).to receive(:total).and_return(order.gross_total)
    end

    after do
      cleanup_stripe_objects
      VCR.turn_on!
    end

    it "creates Charge and Payments to execute a credit card payment for an order" do
      res = subject.perform(params)

      expect(res.success?).to be true

      order = res.order
      expect(order).to be order
      expect(order.valid?).to be true
      expect(order.errors.empty?).to be true
      expect(order.payment_method).to eq payment_method
      expect(order.payment_status).to eq 'paid'

      order.items.each do |item|
        item.reload
        expect(item.payment_status).to eq 'paid'
      end

      payment = res.payment
      expect(payment).to be
      expect(payment).to eq order.payments.first
      expect(payment.status).to eq 'paid'
      expect(payment.amount).to eq "6".to_d
      expect(payment.stripe_payment_fee).to eq "0.47".to_d
      expect(payment.payer).to eq buyer_organization
      expect(payment.payment_method).to eq payment_method
      expect(payment.bank_account_id).to eq credit_card.id

      # We know there's only one order item. so lets assume the payment fee
      # has been fully allocated to this one item:
      expect(order.items.first.payment_seller_fee).to eq("0.47".to_d)
      
      charge_id = payment.stripe_id
      expect(charge_id).to be
      charge = Stripe::Charge.retrieve(charge_id)
      expect(charge).to be
      expect(charge.amount).to eq 600
      expect(charge.currency).to eq 'usd'
      expect(charge.status).to eq 'succeeded'
      expect(charge.metadata['lo.payment_id']).to eq payment.id.to_s
      expect(charge.metadata['lo.order_id']).to eq order.id.to_s
      expect(charge.metadata['lo.order_number']).to eq order.order_number

      application_fee = Stripe::ApplicationFee.retrieve(charge.application_fee)
      expect(application_fee).to be
      expect(application_fee.amount).to eq 47

    end

  end
end
