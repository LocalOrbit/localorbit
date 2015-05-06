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

end
