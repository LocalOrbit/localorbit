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
          charge = create_stripe(:charge, status: input)
          translated = subject.translate_status(charge: charge, cart: nil, payment_method: 'unused')
          expect(translated).to eq(output), "Expected status '#{input}' to translate to '#{output}' but got '#{translated}'"
        end
      end
    end
  end
end
