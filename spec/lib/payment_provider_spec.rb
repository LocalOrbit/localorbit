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


    describe ".supports_payment_method" do
      it "checks the provider for supported payment methods and returns true or false" do
        provider_object.supported_payment_methods.each do |good|
          expect(PaymentProvider.supports_payment_method?(provider_name, good)).to eq true
        end
        expect(PaymentProvider.supports_payment_method?(provider_name, :no_chance)).to eq false
        expect(PaymentProvider.supports_payment_method?(provider_name, nil)).to eq false
      end
    end

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

    describe ".translate_status" do
      let(:params) {
        { charge: 'the charge', 
          payment_method: 'the payment method', 
          cart: 'the cart' }
      }
      it "delegates to #{provider_object.name}.translate_status" do
        expect(provider_object).to receive(:translate_status).with(params)
        PaymentProvider.translate_status provider_name, params
      end
    end


  end # end each provider loop
end

