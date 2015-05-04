describe PaymentProvider::Stripe do
  subject { described_class } 

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
