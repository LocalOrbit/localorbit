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
        charge = create_stripe(:charge, status: input)
        translated = subject.translate_status(charge: charge, cart: 'wat', payment_method: 'evar')
        expect(translated).to eq(output), "Expected status '#{input}' to translate to '#{output}' but got '#{translated}'"
      end
    end

    it "returns 'failed' for nil charge" do
      translated = subject.translate_status(charge: nil, cart: 'wat', payment_method: 'evar')
      expect(translated).to eq('failed')
    end
  end

end
