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

end
