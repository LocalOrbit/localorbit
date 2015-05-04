require "spec_helper"

describe CreateStripeCustomerForEntity do

  before :all do
    VCR.turn_off!
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

    context "when Stripe customer doesn't yet exist for the entity" do
      let!(:org) { create(:organization, name: "Customer Creation Tests") }

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
      let!(:org) { create(:organization, name: "Customer Creation Testes") }

      it "keeps the existing customer" do
        # Setup a customer:
        result = subject.perform(entity: org)

        # Peek, see it's good:
        expect(org.stripe_customer_id).to be
        customer = Stripe::Customer.retrieve(org.stripe_customer_id)
        expect(customer).to be
        delete_later customer

        # Remember the id:
        existing_customer_id = org.stripe_customer_id

        # DO AGAIN:
        result2 = subject.perform(entity: org)
        expect(result.success?).to be true

        expect(result.success?).to be true
        if org.stripe_customer_id != existing_customer_id
          customer2 = Stripe::Customer.retrieve(org.stripe_customer_id)
          p customer2
          delete_later customer2
        end
        expect(org.stripe_customer_id).to eq existing_customer_id 
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
