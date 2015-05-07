describe PaymentProvider::Balanced do
  subject { described_class } 

  describe ".supported_payment_methods" do
    it "has 'credit card' and 'ach'" do
      expect(subject.supported_payment_methods).to eq ['credit card', 'ach']
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
      expect(PlaceOrder).to receive(:perform).with(
        payment_provider: :balanced,
        entity: params[:buyer_organization],
        buyer: params[:user],
        order_params: params[:order_params],
        cart: params[:cart]
      )

      subject.place_order(params)
    end
  end

  describe ".translate_status" do
    context "when :cart is supplied" do
      it "is 'paid' when cart total is 0 or payment method is CC, 'pending' otherwise" do
        cart = Cart.new
        expect(cart).to receive(:total).and_return(0)
        expect(subject.translate_status(charge: 'unused', cart: cart, payment_method: 'whatever')).to eq 'paid'

        expect(cart).to receive(:total).and_return(10)
        expect(subject.translate_status(charge: 'unused', cart: cart, payment_method: 'credit card')).to eq 'paid'

        expect(cart).to receive(:total).and_return(10)
        expect(subject.translate_status(charge: 'unused', cart: cart, payment_method: 'ach')).to eq 'pending'
      end
    end

    context "when :cart is NOT supplied" do
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
          debit = double "the debit", status: input
          translated = subject.translate_status(charge: debit, cart: nil, payment_method: 'unused')
          expect(translated).to eq(output), "Expected status '#{input}' to translate to '#{output}' but got '#{translated}'"
        end
      end
    end
  end

  describe ".charge_for_order" do
    # Simple "double-books accounting"-style test for Balanced implementation.  
    # This interaction spec is based on an implementation that is known to work due to past
    # use and testing.  Expecting to delete this bugger soon, anyway.
    let(:amount)       { "123.45".to_d }
    let(:market)       { double "the market", name: "The Cold Sto", on_statement_as: "COLD STO!" }
    let(:order)        { double "the order", order_number: "123-order-456" }
    let(:bank_account) { double "the bank account", balanced_uri: "/bank/acct/balanced/uri" }
    let(:customer)     { double "the balanced customer" }
    let(:buyer_organization) { double "the buyer", balanced_customer: customer }
    let(:debit)        { double "the resulting debit" }

    it "creates a debit using the Balanced customer of the buying organization" do

      amount_in_cents = ::Financials::MoneyHelpers.amount_to_cents(amount)

      expect(customer).to receive(:debit).with(
        amount: amount_in_cents,
        source_uri: bank_account.balanced_uri,
        description: "The Cold Sto purchase",
        appears_on_statement_as: "COLD STO!",
        meta: { 'order number' => order.order_number }
      ).and_return(debit)

      subject.charge_for_order(
        amount: amount,
        bank_account: bank_account,
        market: market,
        order: order,
        buyer_organization: buyer_organization)

    end
  end

  describe ".fully_refund" do
    context "(interaction tests)" do
      let(:debit) { double "the debit" }
      let(:payment) { double "the payment", balanced_uri: "the payment balanced uri" }
      # let(:order) { double "the order", id: 'the order id', order_number: "the order number" }
      # let(:refund_list) { double "the list of refunds" }
      let(:new_refund) { double "the new refund" }
      
      it "refunds the debit" do
        expect(debit).to receive(:refund).and_return(new_refund)

        ref = subject.fully_refund(
          charge: debit,
          payment: payment,
          order: "unused"
        )

        expect(ref).to be new_refund
      end

      it "looks up the charge based on payment balanced_uri if not provided as arg" do
        expect(Balanced::Debit).to receive(:find).with(payment.balanced_uri).and_return(debit)

        expect(debit).to receive(:refund).and_return(new_refund)

        ref = subject.fully_refund(
          payment: payment,
          order: "unused"
        )

        expect(ref).to be new_refund
      end
    end # end interaction tests

  end

  describe ".store_payment_fees" do
    it "does nothing" do
      expect(subject.store_payment_fees(order: "whatever")).to be nil
    end
  end

  describe ".create_order_payment" do
    include_context "the mini market"

    let(:debit) { double "the debit", uri: "debit balanced uri" }
    let(:bank_account) { create(:bank_account, :credit_card) }
    let(:params) {
      {
        charge: debit,
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
      payment = subject.create_order_payment(params)
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
      expect(payment.balanced_uri).to eq debit.uri
    end

    context "when the charge is nil" do
      it "leaves the balanced_uri unset" do
        params[:charge] = nil
        payment = subject.create_order_payment(params)
        expect(payment.balanced_uri).to be nil
      end
    end

  end

end
