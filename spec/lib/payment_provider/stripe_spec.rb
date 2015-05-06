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

end
