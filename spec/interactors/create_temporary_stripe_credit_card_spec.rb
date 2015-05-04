require "spec_helper"

describe CreateTemporaryStripeCreditCard do

  before :all do
    VCR.turn_off!  # CUT! CUT! CUT! 
  end

  after :all do
    VCR.turn_on!
  end

  def delete_later(obj)
    @objects_to_delete ||= []
    @objects_to_delete << obj
  end

  after do
    (@objects_to_delete || []).each do |obj|
      begin
        obj.delete
      rescue Exception => e
        puts "(Error while trying to delete #{obj.inspect}: #{e.message})"
      end 
    end
  end


  context "integration tests" do
    subject { described_class }

    context "credit card not yet on file" do
      let!(:org) { create(:organization, name: "Customer Creation Tests") }
      let!(:cart) { create(:organization, name: "Customer Creation Tests") }

      it "creates a new Stripe customer and associates it with the entity" do
        result = subject.perform(entity: org)

        expect(result.success?).to be true
        expect(org.stripe_customer_id).to be

        customer = Stripe::Customer.retrieve(org.stripe_customer_id)
        expect(customer).to be
        delete_later customer
        expect(customer.description).to eq org.name
        expect(customer.metadata["lo.entity_type"]).to eq 'organization'
        expect(customer.metadata["lo.entity_id"]).to eq org.id.to_s
      end
    end

    context "when Stripe customer already associated with the entity" do
      let!(:org)       { create(:organization, name: "Customer Creation Testes") }
      let!(:cart)      { create(:cart, organization: org) }
      let!(:order) { create(:order) }

      let(:order_params) {
        HashWithIndifferentAccess.new(
          payment_method: "credit card",
          credit_card: HashWithIndifferentAccess.new(
            account_type: "visa",
            last_four: "1111",
            bank_name: "House of Test",
            name: "My Test Visa"
          )
        )
      }

      it "creates a new BankAccount and Stripe::Customer" do
        raise "WIP"
        # binding.pry
        #
        # result = subject.perform(order_params: order_params, cart: card, order: order)
        #
        # expect(result.success?).to be true
        #
        # bank_account_id = result.context[:order_params]["credit_card"]["id"]
        # bank_account = BankAccount.find(bank_account_id)
        # Stripe::Customer.    bank_account.stripe_id
        # expect(result.context[:order_params]["credit_card"]["id"]).to be
      end
    end
  end

  # context "interaction-based tests" do
    # context "when Stripe customer doesn't yet exist" do
      # let!(:entity) { create(:organization, name: "Fake Organization") }
      
      # subject { CreateBalancedCustomerForEntity.perform(entity: entity) }
      
      # it "creates a balanced customer" do
      #   expect(Balanced::Customer).to receive(:new).and_return(double("Balanced Customer", save: double("Balanced Customer", uri: "/balanced-customer-uri")))
      #
      #   expect {
      #     subject
      #   }.to change {
      #     entity.balanced_customer_uri
      #   }.from(nil).to("/balanced-customer-uri")
      # end
    # end

    # context "stripe customer already exists" do
      # let!(:entity) { create(:organization, name: "Fake Organization", balanced_customer_uri: "/existing-balanced-customer") }
      #
      # subject { CreateBalancedCustomerForEntity.perform(entity: entity) }
      #
      # it "does not create a balanced customer" do
      #   expect(Balanced::Customer).to_not receive(:new)
      #
      #   expect {
      #     subject
      #   }.to_not change {
      #     entity.balanced_customer_uri
      #   }.from("/existing-balanced-customer")
      # end
    # end
  # end # end interaction tests
end
