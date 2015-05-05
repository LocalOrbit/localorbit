describe PaymentProvider do
  # subject { described_class } 

  describe ".for" do
    it "returns the mapped provider object" do
      expect(PaymentProvider.for(:stripe)).to be(PaymentProvider::Stripe)
      expect(PaymentProvider.for(:balanced)).to be(PaymentProvider::Balanced)
    end

    it "accepts string identifiers as well as symbols" do
      expect(PaymentProvider.for('stripe')).to be(PaymentProvider::Stripe)
      expect(PaymentProvider.for('balanced')).to be(PaymentProvider::Balanced)
    end

    it "raises for unknown providers" do
      expect(lambda { PaymentProvider.for('wat') }).to raise_error(/wat/i)
    end
  end

  describe ".is_balanced?" do
    it "returns true if the given identifier corresponds to Balanced, false otherwise" do
      expect(PaymentProvider.is_balanced?(PaymentProvider::Balanced.id)).to be true
      expect(PaymentProvider.is_balanced?(:balanced)).to be true
      expect(PaymentProvider.is_balanced?('balanced')).to be true
      expect(PaymentProvider.is_balanced?(PaymentProvider::Stripe.id)).to be false
      expect(PaymentProvider.is_balanced?(:other)).to be false
      expect(PaymentProvider.is_balanced?(nil)).to be false
    end
  end


  [
    PaymentProvider::Balanced.id,
    PaymentProvider::Stripe.id,

  ].each do |provider_name|
    provider_object = PaymentProvider.for(provider_name)

    describe ".place_order" do
      let(:params) {
        { buyer_organization: 'the buyer', 
          user: 'the user', 
          order_params: 'the order', 
          cart: 'the cart' }
      }
      it "delegates to #{provider_object.name}.place_order" do
        expect(provider_object).to receive(:place_order).with(params)
        PaymentProvider.place_order provider_name, params
      end
    end


  end # end each provider loop
end

